# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  description :text
#  position    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Category < ApplicationRecord
  # =============================================================================
  # FriendlyId for SEO-friendly URLs
  # =============================================================================
  extend FriendlyId
  friendly_id :name, use: :slugged

  # =============================================================================
  # Associations
  # =============================================================================
  has_many :work_categories, dependent: :destroy
  has_many :works, through: :work_categories

  # =============================================================================
  # Validations
  # =============================================================================
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }

  # =============================================================================
  # Scopes
  # =============================================================================
  scope :ordered, -> { order(position: :asc, name: :asc) }
  scope :with_published_works, -> { joins(:works).where(works: { published: true }).distinct }

  # =============================================================================
  # Instance Methods
  # =============================================================================
  def published_works_count
    works.published.count
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || slug.blank?
  end
end
