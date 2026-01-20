# frozen_string_literal: true

# == Schema Information
#
# Table name: work_categories
#
#  id          :bigint           not null, primary key
#  work_id     :bigint           not null
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class WorkCategory < ApplicationRecord
  # =============================================================================
  # Associations
  # =============================================================================
  belongs_to :work
  belongs_to :category

  # =============================================================================
  # Validations
  # =============================================================================
  validates :work_id, uniqueness: { scope: :category_id }
end
