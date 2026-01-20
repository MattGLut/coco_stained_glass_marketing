# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkCategory, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:work) }
    it { is_expected.to belong_to(:category) }
  end

  describe "validations" do
    subject { create(:work_category) }

    it { is_expected.to validate_uniqueness_of(:work_id).scoped_to(:category_id) }

    it "prevents duplicate work-category associations" do
      work = create(:work)
      category = create(:category)
      create(:work_category, work: work, category: category)

      duplicate = build(:work_category, work: work, category: category)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:work_id]).to be_present
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:work_category)).to be_valid
    end
  end
end
