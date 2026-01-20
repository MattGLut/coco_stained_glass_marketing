# frozen_string_literal: true

# == Schema Information
#
# Table name: commissions
#
#  id                        :bigint           not null, primary key
#  user_id                   :bigint           not null
#  title                     :string           not null
#  description               :text
#  customer_notes            :text
#  internal_notes            :text
#  status                    :string           default("inquiry"), not null
#  estimated_start_date      :date
#  estimated_completion_date :date
#  actual_start_date         :date
#  actual_completion_date    :date
#  delivered_at              :date
#  estimated_price           :decimal(10, 2)
#  final_price               :decimal(10, 2)
#  deposit_amount            :decimal(10, 2)
#  deposit_paid              :boolean          default(FALSE)
#  deposit_paid_at           :date
#  dimensions                :string
#  location                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
class Commission < ApplicationRecord
  include AASM

  # =============================================================================
  # Active Storage Attachments
  # =============================================================================
  has_many_attached :reference_images do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
    attachable.variant :medium, resize_to_limit: [600, 600]
  end

  has_many_attached :progress_images do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
    attachable.variant :medium, resize_to_limit: [600, 600]
    attachable.variant :large, resize_to_limit: [1200, 1200]
  end

  has_many_attached :final_images do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
    attachable.variant :medium, resize_to_limit: [600, 600]
    attachable.variant :large, resize_to_limit: [1200, 1200]
  end

  # =============================================================================
  # Associations
  # =============================================================================
  belongs_to :user
  has_many :commission_updates, dependent: :destroy

  # =============================================================================
  # Validations
  # =============================================================================
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 5000 }
  validates :customer_notes, length: { maximum: 2000 }
  validates :internal_notes, length: { maximum: 5000 }
  validates :dimensions, length: { maximum: 100 }
  validates :location, length: { maximum: 200 }
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :final_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :deposit_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # =============================================================================
  # AASM State Machine
  # =============================================================================
  aasm column: :status do
    # States
    state :inquiry, initial: true       # Initial inquiry from customer
    state :quoted                       # Quote has been provided
    state :accepted                     # Customer accepted the quote
    state :deposit_received             # Deposit has been paid
    state :in_progress                  # Work has begun
    state :review                       # Ready for customer review/approval
    state :completed                    # Work is finished
    state :delivered                    # Delivered to customer
    state :cancelled                    # Cancelled by either party

    # Transitions
    event :provide_quote do
      transitions from: :inquiry, to: :quoted
    end

    event :accept do
      transitions from: :quoted, to: :accepted
    end

    event :receive_deposit do
      transitions from: :accepted, to: :deposit_received
      after do
        update(deposit_paid: true, deposit_paid_at: Date.current)
      end
    end

    event :start_work do
      transitions from: [:accepted, :deposit_received], to: :in_progress
      after do
        update(actual_start_date: Date.current) if actual_start_date.nil?
      end
    end

    event :submit_for_review do
      transitions from: :in_progress, to: :review
    end

    event :request_changes do
      transitions from: :review, to: :in_progress
    end

    event :complete do
      transitions from: [:in_progress, :review], to: :completed
      after do
        update(actual_completion_date: Date.current) if actual_completion_date.nil?
      end
    end

    event :deliver do
      transitions from: :completed, to: :delivered
      after do
        update(delivered_at: Date.current)
      end
    end

    event :cancel do
      transitions from: [:inquiry, :quoted, :accepted, :deposit_received, :in_progress], to: :cancelled
    end

    event :reopen do
      transitions from: :cancelled, to: :inquiry
    end
  end

  # =============================================================================
  # Scopes
  # =============================================================================
  scope :active, -> { where.not(status: [:delivered, :cancelled]) }
  scope :for_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # =============================================================================
  # Instance Methods
  # =============================================================================
  def customer
    user
  end

  def customer_name
    user.full_name
  end

  def customer_email
    user.email
  end

  def status_label
    status.humanize.titleize
  end

  def status_color_class
    case status
    when "inquiry" then "status-badge--inquiry"
    when "quoted", "accepted" then "status-badge--accepted"
    when "deposit_received", "in_progress", "review" then "status-badge--in_progress"
    when "completed" then "status-badge--completed"
    when "delivered" then "status-badge--delivered"
    when "cancelled" then "status-badge--cancelled"
    else "status-badge--default"
    end
  end

  def progress_percentage
    case status
    when "inquiry" then 5
    when "quoted" then 15
    when "accepted" then 25
    when "deposit_received" then 35
    when "in_progress" then 60
    when "review" then 80
    when "completed" then 95
    when "delivered" then 100
    else 0
    end
  end

  def days_since_start
    return nil unless actual_start_date
    (Date.current - actual_start_date).to_i
  end

  def days_until_estimated_completion
    return nil unless estimated_completion_date
    (estimated_completion_date - Date.current).to_i
  end

  def overdue?
    return false unless estimated_completion_date && !completed? && !delivered? && !cancelled?
    Date.current > estimated_completion_date
  end

  def visible_updates
    commission_updates.where(visible_to_customer: true).order(created_at: :desc)
  end

  def price_display
    final_price || estimated_price
  end

  def deposit_outstanding?
    deposit_amount.present? && deposit_amount > 0 && !deposit_paid?
  end
end
