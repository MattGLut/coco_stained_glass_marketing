# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sitemaps", type: :request do
  describe "GET /sitemap.xml" do
    let!(:published_work) { create(:work, published: true, title: "Published Work") }
    let!(:draft_work) { create(:work, published: false, title: "Draft Work") }
    let!(:category_with_works) { create(:category, name: "Windows") }
    let!(:empty_category) { create(:category, name: "Empty Category") }

    before do
      published_work.categories << category_with_works
    end

    it "returns success" do
      get "/sitemap.xml"
      expect(response).to have_http_status(:success)
    end

    it "returns XML content type" do
      get "/sitemap.xml"
      expect(response.content_type).to include("application/xml")
    end

    it "includes published works" do
      get "/sitemap.xml"
      expect(response.body).to include(work_url(published_work))
    end

    it "does not include draft works" do
      get "/sitemap.xml"
      expect(response.body).not_to include(draft_work.slug)
    end

    it "includes categories with published works" do
      get "/sitemap.xml"
      expect(response.body).to include("category=#{category_with_works.id}")
    end
  end
end
