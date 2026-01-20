# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  first_name             :string
#  last_name              :string
#  phone                  :string
#  role                   :integer          default("customer"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  # =============================================================================
  # Devise modules
  # =============================================================================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  # =============================================================================
  # Enums
  # =============================================================================
  enum :role, { customer: 0, admin: 1 }, default: :customer

  # =============================================================================
  # Associations
  # =============================================================================
  has_many :commissions, dependent: :destroy

  # =============================================================================
  # Validations
  # =============================================================================
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :phone, length: { maximum: 20 }, allow_blank: true

  # =============================================================================
  # Callbacks
  # =============================================================================
  before_save :downcase_email

  # =============================================================================
  # Instance Methods
  # =============================================================================
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.presence || email
  end

  # Check if user can access admin area
  def admin_access?
    admin?
  end

  # Check if user can access customer portal
  def portal_access?
    customer? || admin?
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end
