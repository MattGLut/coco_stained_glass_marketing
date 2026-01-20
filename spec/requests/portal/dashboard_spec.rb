# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Portal::Dashboard", type: :request do
  describe "GET /portal" do
    context "when not signed in" do
      it "redirects to sign in" do
        get portal_dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as customer" do
      let(:customer) { create(:user, :customer) }

      before { sign_in customer }

      it "returns success" do
        get portal_dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "displays welcome message" do
        get portal_dashboard_path
        expect(response.body).to include("Welcome back")
      end

      context "with commissions" do
        let!(:active_commission) { create(:commission, :in_progress, user: customer, title: "Active Project") }
        let!(:completed_commission) { create(:commission, :delivered, user: customer, title: "Completed Project") }

        it "displays active commissions" do
          get portal_dashboard_path
          expect(response.body).to include("Active Project")
        end

        it "displays completed commissions" do
          get portal_dashboard_path
          expect(response.body).to include("Completed Project")
        end
      end
    end
  end
end
