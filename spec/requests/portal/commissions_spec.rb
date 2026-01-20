# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Portal::Commissions", type: :request do
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get portal_commissions_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when signed in as customer" do
    before { sign_in customer }

    describe "GET /portal/commissions" do
      let!(:my_commission) { create(:commission, user: customer, title: "My Project") }
      let!(:other_commission) { create(:commission, user: other_customer, title: "Other Project") }

      it "returns success" do
        get portal_commissions_path
        expect(response).to have_http_status(:success)
      end

      it "displays customer's commissions" do
        get portal_commissions_path
        expect(response.body).to include("My Project")
      end

      it "does not display other customers' commissions" do
        get portal_commissions_path
        expect(response.body).not_to include("Other Project")
      end
    end

    describe "GET /portal/commissions/:id" do
      let(:commission) { create(:commission, user: customer, title: "My Commission") }
      let!(:visible_update) { create(:commission_update, commission: commission, title: "Progress Update", visible_to_customer: true) }
      let!(:internal_update) { create(:commission_update, commission: commission, title: "Internal Note", visible_to_customer: false) }

      it "returns success" do
        get portal_commission_path(commission)
        expect(response).to have_http_status(:success)
      end

      it "displays commission details" do
        get portal_commission_path(commission)
        expect(response.body).to include("My Commission")
      end

      it "displays visible updates" do
        get portal_commission_path(commission)
        expect(response.body).to include("Progress Update")
      end

      it "does not display internal updates" do
        get portal_commission_path(commission)
        expect(response.body).not_to include("Internal Note")
      end

      context "accessing another customer's commission" do
        let(:other_commission) { create(:commission, user: other_customer) }

        it "raises not found error" do
          get portal_commission_path(other_commission)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  context "when signed in as admin" do
    let(:admin) { create(:user, :admin) }

    before { sign_in admin }

    describe "GET /portal/commissions" do
      it "returns success" do
        get portal_commissions_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
