# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          first_name: "New",
          last_name: "User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates a new user" do
      expect {
        post user_registration_path, params: valid_params
      }.to change(User, :count).by(1)
    end

    it "redirects to portal dashboard after sign up" do
      post user_registration_path, params: valid_params
      # New user needs to confirm email first if confirmable is enabled
      # If the user is auto-confirmed or confirmable is disabled, redirect to portal
      user = User.find_by(email: "newuser@example.com")
      if user.confirmed?
        expect(response).to redirect_to(portal_dashboard_path)
      else
        # With confirmable, redirects to root or a "check your email" page
        expect(response).to be_redirect
      end
    end
  end

  describe "PATCH /users" do
    context "when signed in as an admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "redirects to admin dashboard after update" do
        patch user_registration_path, params: {
          user: {
            first_name: "Updated",
            current_password: "password123"
          }
        }
        expect(response).to redirect_to(admin_root_path)
      end
    end

    context "when signed in as a customer" do
      let(:customer) { create(:user, :customer) }

      before { sign_in customer }

      it "redirects to portal dashboard after update" do
        patch user_registration_path, params: {
          user: {
            first_name: "Updated",
            current_password: "password123"
          }
        }
        expect(response).to redirect_to(portal_dashboard_path)
      end
    end
  end
end
