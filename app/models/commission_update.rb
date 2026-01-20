# frozen_string_literal: true

# == Schema Information
#
# Table name: commission_updates
#
#  id                  :bigint           not null, primary key
#  commission_id       :bigint           not null
#  user_id             :bigint
#  title               :string           not null
#  body                :text
#  notify_customer     :boolean          default(TRUE)
#  visible_to_customer :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class CommissionUpdate < ApplicationRecord
  # =============================================================================
  # Active Storage Attachments
  # =============================================================================
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_fill: [200, 200]
    attachable.variant :medium, resize_to_limit: [600, 600]
    attachable.variant :large, resize_to_limit: [1200, 1200]
  end

  # =============================================================================
  # Associations
  # =============================================================================
  belongs_to :commission
  belongs_to :user, optional: true  # Admin who created the update

  # =============================================================================
  # Validations
  # =============================================================================
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, length: { maximum: 5000 }

  # =============================================================================
  # Scopes
  # =============================================================================
  scope :visible_to_customer, -> { where(visible_to_customer: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  # =============================================================================
  # Callbacks
  # =============================================================================
  after_create :send_notification, if: :should_notify?

  # =============================================================================
  # Instance Methods
  # =============================================================================
  def author_name
    user&.full_name || "Coco's Stained Glass"
  end

  def has_images?
    images.attached?
  end

  def formatted_date
    created_at.strftime("%B %d, %Y")
  end

  def formatted_time
    created_at.strftime("%I:%M %p")
  end

  private

  def should_notify?
    notify_customer && visible_to_customer && commission.user.present?
  end

  def send_notification
    CommissionMailer.update_notification(self).deliver_later
  end
end
