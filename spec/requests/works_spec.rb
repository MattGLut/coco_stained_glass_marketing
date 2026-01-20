# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Works", type: :request do
  describe "GET /gallery" do
    let!(:published_work) { create(:work, published: true, title: "Published Work") }
    let!(:draft_work) { create(:work, published: false, title: "Draft Work") }

    it "returns success" do
      get works_path
      expect(response).to have_http_status(:success)
    end

    it "displays published works" do
      get works_path
      expect(response.body).to include("Published Work")
    end

    it "does not display draft works" do
      get works_path
      expect(response.body).not_to include("Draft Work")
    end

    context "with category filter" do
      let(:category) { create(:category, name: "Windows") }
      let!(:categorized_work) { create(:work, published: true, title: "Window Piece", categories: [category]) }
      let!(:uncategorized_work) { create(:work, published: true, title: "Other Piece") }

      it "filters by category" do
        get works_path(category: category.id)
        expect(response.body).to include("Window Piece")
        expect(response.body).not_to include("Other Piece")
      end
    end
  end

  describe "GET /gallery/:id" do
    let(:work) { create(:work, published: true, title: "Test Work", description: "A beautiful piece") }

    it "returns success for published work" do
      get work_path(work)
      expect(response).to have_http_status(:success)
    end

    it "displays work details" do
      get work_path(work)
      expect(response.body).to include("Test Work")
      expect(response.body).to include("A beautiful piece")
    end

    it "returns 404 for draft work" do
      draft_work = create(:work, published: false)
      get work_path(draft_work)
      expect(response).to have_http_status(:not_found)
    end
  end
end
