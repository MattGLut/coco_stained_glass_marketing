# frozen_string_literal: true

require "rails_helper"

RSpec.describe Work, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:work)).to be_valid
    end

    it "has a valid featured factory" do
      expect(build(:work, :featured)).to be_valid
    end

    it "has a valid draft factory" do
      expect(build(:work, :draft)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:work_categories).dependent(:destroy) }
    it { is_expected.to have_many(:categories).through(:work_categories) }
    it { is_expected.to have_many_attached(:images) }
  end

  describe "validations" do
    subject { build(:work) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    it "declares a presence validation on slug" do
      expect(Work.validators_on(:slug).map(&:class)).to include(ActiveRecord::Validations::PresenceValidator)
    end

    it "declares a uniqueness validation on slug" do
      expect(Work.validators_on(:slug).any? { |v| v.is_a?(ActiveRecord::Validations::UniquenessValidator) }).to be true
    end
    it { is_expected.to validate_length_of(:dimensions).is_at_most(100) }
    it { is_expected.to validate_length_of(:medium).is_at_most(200) }

    describe "year_created" do
      it "allows nil" do
        work = build(:work, year_created: nil)
        expect(work).to be_valid
      end

      it "rejects years before 1900" do
        work = build(:work, year_created: 1899)
        expect(work).not_to be_valid
      end

      it "rejects future years" do
        work = build(:work, year_created: Date.current.year + 1)
        expect(work).not_to be_valid
      end

      it "accepts valid years" do
        work = build(:work, year_created: 2020)
        expect(work).to be_valid
      end
    end
  end

  describe "scopes" do
    let!(:published_work) { create(:work, published: true) }
    let!(:draft_work) { create(:work, published: false) }
    let!(:featured_work) { create(:work, featured: true, published: true) }

    describe ".published" do
      it "returns only published works" do
        expect(Work.published).to include(published_work, featured_work)
        expect(Work.published).not_to include(draft_work)
      end
    end

    describe ".draft" do
      it "returns only draft works" do
        expect(Work.draft).to include(draft_work)
        expect(Work.draft).not_to include(published_work)
      end
    end

    describe ".featured" do
      it "returns only featured works" do
        expect(Work.featured).to include(featured_work)
        expect(Work.featured).not_to include(published_work)
      end
    end

    describe ".ordered" do
      it "orders by position ascending then created_at descending" do
        old_work = create(:work, position: 1, created_at: 2.days.ago)
        new_work = create(:work, position: 1, created_at: 1.day.ago)
        first_work = create(:work, position: 0)

        result = Work.ordered
        expect(result.index(first_work)).to be < result.index(new_work)
        expect(result.index(new_work)).to be < result.index(old_work)
      end
    end

    describe ".recent" do
      it "orders by created_at descending" do
        old_work = create(:work, created_at: 2.days.ago)
        new_work = create(:work, created_at: 1.day.ago)

        result = Work.recent.where(id: [old_work.id, new_work.id])
        expect(result.first).to eq(new_work)
        expect(result.last).to eq(old_work)
      end
    end

    describe ".by_year" do
      it "returns works from the given year" do
        work_2022 = create(:work, year_created: 2022)
        work_2023 = create(:work, year_created: 2023)

        expect(Work.by_year(2022)).to include(work_2022)
        expect(Work.by_year(2022)).not_to include(work_2023)
      end
    end

    describe ".in_category" do
      it "returns works in the given category" do
        category = create(:category)
        in_cat = create(:work, categories: [category])
        out_cat = create(:work)

        expect(Work.in_category(category.id)).to include(in_cat)
        expect(Work.in_category(category.id)).not_to include(out_cat)
      end
    end
  end

  describe "#full_title" do
    it "includes year when present" do
      work = build(:work, title: "Sunset Panel", year_created: 2022)
      expect(work.full_title).to eq("Sunset Panel (2022)")
    end

    it "returns title only when year is nil" do
      work = build(:work, title: "Sunset Panel", year_created: nil)
      expect(work.full_title).to eq("Sunset Panel")
    end
  end

  describe "#meta_description" do
    it "truncates long descriptions" do
      long_description = "A" * 200
      work = build(:work, description: long_description)
      expect(work.meta_description.length).to be <= 160
    end

    it "uses default when description is blank" do
      work = build(:work, title: "Test Work", description: nil)
      expect(work.meta_description).to include("Test Work")
    end
  end

  describe "#category_names" do
    it "returns comma-separated category names" do
      work = create(:work)
      cat1 = create(:category, name: "Windows")
      cat2 = create(:category, name: "Panels")
      work.categories << [cat1, cat2]

      expect(work.category_names).to include("Windows")
      expect(work.category_names).to include("Panels")
    end
  end

  describe "FriendlyId" do
    it "generates a slug from title" do
      work = create(:work, title: "Beautiful Sunrise Window")
      expect(work.slug).to eq("beautiful-sunrise-window")
    end

    it "updates slug when title changes" do
      work = create(:work, title: "Original Title")
      work.update(title: "New Title")
      expect(work.slug).to eq("new-title")
    end
  end
end
