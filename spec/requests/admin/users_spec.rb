# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get admin_users_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects customers to root with alert" do
      sign_in customer
      get admin_users_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/users" do
      let!(:admin_user) { create(:user, :admin, first_name: "Admin", last_name: "User") }
      let!(:customer_user) { create(:user, :customer, first_name: "Customer", last_name: "User") }

      it "returns success" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "displays all users" do
        get admin_users_path
        expect(response.body).to include("Admin User")
        expect(response.body).to include("Customer User")
      end

      it "filters by admin role" do
        get admin_users_path(role: "admin")
        expect(response.body).to include("Admin User")
      end

      it "filters by customer role" do
        get admin_users_path(role: "customer")
        expect(response.body).to include("Customer User")
      end
    end

    describe "GET /admin/users/:id" do
      let(:user) { create(:user, :customer, first_name: "Test", last_name: "Customer") }

      it "returns success" do
        get admin_user_path(user)
        expect(response).to have_http_status(:success)
      end

      it "displays user details" do
        get admin_user_path(user)
        expect(response.body).to include("Test Customer")
      end

      it "displays user commissions" do
        commission = create(:commission, user: user, title: "Custom Glass Window")
        get admin_user_path(user)
        expect(response.body).to include("Custom Glass Window")
      end
    end

    describe "GET /admin/users/:id/edit" do
      let(:user) { create(:user, :customer) }

      it "returns success" do
        get edit_admin_user_path(user)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/users/:id" do
      let(:user) { create(:user, :customer, first_name: "Original") }

      context "with valid params" do
        it "updates the user" do
          patch admin_user_path(user), params: { user: { first_name: "Updated" } }
          expect(user.reload.first_name).to eq("Updated")
        end

        it "redirects to the user page" do
          patch admin_user_path(user), params: { user: { first_name: "Updated" } }
          expect(response).to redirect_to(admin_user_path(user))
        end

        it "sets a success notice" do
          patch admin_user_path(user), params: { user: { first_name: "Updated" } }
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid params" do
        it "renders the form with errors" do
          patch admin_user_path(user), params: { user: { email: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
