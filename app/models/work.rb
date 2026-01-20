# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id           :bigint           not null, primary key
#  title        :string           not null
#  slug         :string           not null
#  description  :text
#  dimensions   :string
#  medium       :string
#  year_created :integer
#  featured     :boolean          default(FALSE)
#  published    :boolean          default(FALSE)
#  position     :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Work < ApplicationRecord
  # =============================================================================
  # FriendlyId for SEO-friendly URLs
  # =============================================================================
  extend FriendlyId
  friendly_id :title, use: :slugged

  # =============================================================================
  # Active Storage Attachments
  # =============================================================================
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_fill: [300, 300]
    attachable.variant :medium, resize_to_limit: [800, 800]
    attachable.variant :large, resize_to_limit: [1400, 1400]
  end

  # =============================================================================
  # Associations
  # =============================================================================
  has_many :work_categories, dependent: :destroy
  has_many :categories, through: :work_categories

  # =============================================================================
  # Validations
  # =============================================================================
  validates :title, presence: true, length: { maximum: 200 }
  validates :slug, presence: true, uniqueness: true
  validates :description, length: { maximum: 2000 }
  validates :dimensions, length: { maximum: 100 }
  validates :medium, length: { maximum: 200 }
  validates :year_created, numericality: { 
    only_integer: true, 
    greater_than: 1900, 
    less_than_or_equal_to: -> { Date.current.year },
    allow_nil: true 
  }

  # =============================================================================
  # Scopes
  # =============================================================================
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :featured, -> { where(featured: true) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_year, ->(year) { where(year_created: year) }
  scope :in_category, ->(category) { joins(:categories).where(categories: { id: category }) }

  # =============================================================================
  # Instance Methods
  # =============================================================================
  def primary_image
    images.first
  end

  def has_images?
    images.attached?
  end

  def category_names
    categories.pluck(:name).join(", ")
  end

  # SEO-friendly title with year
  def full_title
    year_created ? "#{title} (#{year_created})" : title
  end

  # Meta description for SEO
  def meta_description
    description.present? ? description.truncate(160) : "#{title} - Handcrafted stained glass art by Coco"
  end

  private

  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end
end
