# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  describe "POST /users/sign_in" do
    context "when signing in as an admin" do
      let(:admin) { create(:user, :admin) }

      it "redirects to admin dashboard" do
        post user_session_path, params: {
          user: { email: admin.email, password: "password123" }
        }
        expect(response).to redirect_to(admin_root_path)
      end
    end

    context "when signing in as a customer" do
      let(:customer) { create(:user, :customer) }

      it "redirects to portal dashboard" do
        post user_session_path, params: {
          user: { email: customer.email, password: "password123" }
        }
        expect(response).to redirect_to(portal_dashboard_path)
      end
    end
  end

  describe "DELETE /users/sign_out" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "redirects to root path" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end
