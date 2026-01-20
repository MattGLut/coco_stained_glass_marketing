# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:category)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:work_categories).dependent(:destroy) }
    it { is_expected.to have_many(:works).through(:work_categories) }
  end

  describe "validations" do
    subject { build(:category) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    # Note: slug presence/uniqueness is handled by FriendlyId which auto-generates
    # slugs before validation. See "FriendlyId" describe block for slug behavior tests.
    it { is_expected.to validate_length_of(:description).is_at_most(500) }
  end

  describe "scopes" do
    describe ".ordered" do
      it "orders by position then name" do
        cat_c = create(:category, name: "C", position: 1)
        cat_a = create(:category, name: "A", position: 2)
        cat_b = create(:category, name: "B", position: 1)

        expect(Category.ordered).to eq([cat_b, cat_c, cat_a])
      end
    end

    describe ".with_published_works" do
      it "returns categories with published works only" do
        cat_with_published = create(:category)
        cat_with_draft = create(:category)
        cat_empty = create(:category)

        published_work = create(:work, published: true)
        draft_work = create(:work, published: false)

        cat_with_published.works << published_work
        cat_with_draft.works << draft_work

        result = Category.with_published_works
        expect(result).to include(cat_with_published)
        expect(result).not_to include(cat_with_draft)
        expect(result).not_to include(cat_empty)
      end
    end
  end

  describe "#published_works_count" do
    it "returns count of published works" do
      category = create(:category)
      create(:work, published: true, categories: [category])
      create(:work, published: true, categories: [category])
      create(:work, published: false, categories: [category])

      expect(category.published_works_count).to eq(2)
    end
  end

  describe "FriendlyId" do
    it "generates a slug from name" do
      category = create(:category, name: "Stained Glass Windows")
      expect(category.slug).to eq("stained-glass-windows")
    end
  end
end
