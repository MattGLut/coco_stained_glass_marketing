# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Categories", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get admin_categories_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects customers to root with alert" do
      sign_in customer
      get admin_categories_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/categories" do
      let!(:category1) { create(:category, name: "Windows", position: 0) }
      let!(:category2) { create(:category, name: "Panels", position: 1) }

      it "returns success" do
        get admin_categories_path
        expect(response).to have_http_status(:success)
      end

      it "displays all categories" do
        get admin_categories_path
        expect(response.body).to include("Windows")
        expect(response.body).to include("Panels")
      end
    end

    describe "GET /admin/categories/:id" do
      let(:category) { create(:category, name: "Test Category") }
      let!(:work) { create(:work, categories: [category]) }

      it "returns success" do
        get admin_category_path(category)
        expect(response).to have_http_status(:success)
      end

      it "displays category details" do
        get admin_category_path(category)
        expect(response.body).to include("Test Category")
      end
    end

    describe "GET /admin/categories/new" do
      it "returns success" do
        get new_admin_category_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/categories" do
      let(:valid_params) do
        {
          category: {
            name: "New Category",
            description: "A new category for works",
            position: 0
          }
        }
      end

      let(:invalid_params) do
        {
          category: {
            name: "",
            description: "Missing name"
          }
        }
      end

      context "with valid params" do
        it "creates a new category" do
          expect {
            post admin_categories_path, params: valid_params
          }.to change(Category, :count).by(1)
        end

        it "redirects to categories index" do
          post admin_categories_path, params: valid_params
          expect(response).to redirect_to(admin_categories_path)
        end
      end

      context "with invalid params" do
        it "does not create a category" do
          expect {
            post admin_categories_path, params: invalid_params
          }.not_to change(Category, :count)
        end

        it "renders the form with errors" do
          post admin_categories_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "GET /admin/categories/:id/edit" do
      let(:category) { create(:category) }

      it "returns success" do
        get edit_admin_category_path(category)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/categories/:id" do
      let(:category) { create(:category, name: "Original Name") }

      context "with valid params" do
        it "updates the category" do
          patch admin_category_path(category), params: { category: { name: "Updated Name" } }
          expect(category.reload.name).to eq("Updated Name")
        end

        it "redirects to categories index" do
          patch admin_category_path(category), params: { category: { name: "Updated Name" } }
          expect(response).to redirect_to(admin_categories_path)
        end
      end

      context "with invalid params" do
        it "renders the form with errors" do
          patch admin_category_path(category), params: { category: { name: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /admin/categories/:id" do
      let!(:category) { create(:category) }

      it "deletes the category" do
        expect {
          delete admin_category_path(category)
        }.to change(Category, :count).by(-1)
      end

      it "redirects to categories index" do
        delete admin_category_path(category)
        expect(response).to redirect_to(admin_categories_path)
      end
    end
  end
end
