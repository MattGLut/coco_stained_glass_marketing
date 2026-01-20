# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders the home page" do
      get root_path
      expect(response.body).to include("Coco's Stained Glass")
    end

    context "with featured works" do
      let!(:featured_work) { create(:work, :featured, published: true, title: "Featured Piece") }
      let!(:regular_work) { create(:work, published: true, title: "Regular Piece") }

      it "displays featured works" do
        get root_path
        expect(response.body).to include("Featured Piece")
      end
    end
  end

  describe "GET /about" do
    it "returns success" do
      get about_path
      expect(response).to have_http_status(:success)
    end

    it "includes about content" do
      get about_path
      expect(response.body).to include("About")
    end
  end

  describe "GET /contact" do
    it "returns success" do
      get contact_path
      expect(response).to have_http_status(:success)
    end

    it "renders the contact form" do
      get contact_path
      expect(response.body).to include("Get in Touch")
    end
  end
end
