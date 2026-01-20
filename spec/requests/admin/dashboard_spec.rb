# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  describe "GET /admin" do
    context "when not signed in" do
      it "redirects to sign in" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as customer" do
      let(:customer) { create(:user, :customer) }

      before { sign_in customer }

      it "redirects to root with alert" do
        get admin_root_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    context "when signed in as admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "returns success" do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end

      it "displays dashboard" do
        get admin_root_path
        expect(response.body).to include("Dashboard")
      end
    end
  end
end
