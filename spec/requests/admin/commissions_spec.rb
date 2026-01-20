# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Commissions", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      get admin_commissions_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects customers to root with alert" do
      sign_in customer
      get admin_commissions_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "GET /admin/commissions" do
      let!(:inquiry) { create(:commission, status: "inquiry", title: "Inquiry Commission") }
      let!(:in_progress) { create(:commission, :in_progress, title: "In Progress Commission") }

      it "returns success" do
        get admin_commissions_path
        expect(response).to have_http_status(:success)
      end

      it "displays all commissions" do
        get admin_commissions_path
        expect(response.body).to include("Inquiry Commission")
        expect(response.body).to include("In Progress Commission")
      end

      it "filters by status" do
        get admin_commissions_path(status: "inquiry")
        expect(response.body).to include("Inquiry Commission")
        expect(response.body).not_to include("In Progress Commission")
      end
    end

    describe "GET /admin/commissions/:id" do
      let(:commission) { create(:commission, title: "Test Commission") }

      it "returns success" do
        get admin_commission_path(commission)
        expect(response).to have_http_status(:success)
      end

      it "displays commission details" do
        get admin_commission_path(commission)
        expect(response.body).to include("Test Commission")
      end
    end

    describe "GET /admin/commissions/new" do
      it "returns success" do
        get new_admin_commission_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /admin/commissions" do
      let(:customer_user) { create(:user, :customer) }

      let(:valid_params) do
        {
          commission: {
            user_id: customer_user.id,
            title: "New Commission",
            description: "A custom stained glass piece",
            dimensions: "24\" x 36\"",
            estimated_price: 1500
          }
        }
      end

      let(:invalid_params) do
        {
          commission: {
            user_id: customer_user.id,
            title: "",
            description: "Missing title"
          }
        }
      end

      context "with valid params" do
        it "creates a new commission" do
          expect {
            post admin_commissions_path, params: valid_params
          }.to change(Commission, :count).by(1)
        end

        it "redirects to the commission page" do
          post admin_commissions_path, params: valid_params
          expect(response).to redirect_to(admin_commission_path(Commission.last))
        end
      end

      context "with invalid params" do
        it "does not create a commission" do
          expect {
            post admin_commissions_path, params: invalid_params
          }.not_to change(Commission, :count)
        end

        it "renders the form with errors" do
          post admin_commissions_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "GET /admin/commissions/:id/edit" do
      let(:commission) { create(:commission) }

      it "returns success" do
        get edit_admin_commission_path(commission)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/commissions/:id" do
      let(:commission) { create(:commission, title: "Original Title") }

      context "with valid params" do
        it "updates the commission" do
          patch admin_commission_path(commission), params: { commission: { title: "Updated Title" } }
          expect(commission.reload.title).to eq("Updated Title")
        end

        it "redirects to the commission page" do
          patch admin_commission_path(commission), params: { commission: { title: "Updated Title" } }
          expect(response).to redirect_to(admin_commission_path(commission))
        end
      end

      context "with invalid params" do
        it "renders the form with errors" do
          patch admin_commission_path(commission), params: { commission: { title: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /admin/commissions/:id" do
      let!(:commission) { create(:commission) }

      it "deletes the commission" do
        expect {
          delete admin_commission_path(commission)
        }.to change(Commission, :count).by(-1)
      end

      it "redirects to commissions index" do
        delete admin_commission_path(commission)
        expect(response).to redirect_to(admin_commissions_path)
      end
    end

    describe "PATCH /admin/commissions/:id/transition" do
      let(:commission) { create(:commission, status: "inquiry") }

      context "with valid event" do
        it "transitions the commission status" do
          patch transition_admin_commission_path(commission), params: { event: "provide_quote" }
          expect(commission.reload.status).to eq("quoted")
        end

        it "redirects to commission with notice" do
          patch transition_admin_commission_path(commission), params: { event: "provide_quote" }
          expect(response).to redirect_to(admin_commission_path(commission))
          expect(flash[:notice]).to be_present
        end
      end

      context "with invalid event" do
        it "redirects with alert" do
          patch transition_admin_commission_path(commission), params: { event: "invalid_event" }
          expect(response).to redirect_to(admin_commission_path(commission))
          expect(flash[:alert]).to be_present
        end
      end

      context "with event not allowed from current state" do
        it "redirects with alert" do
          patch transition_admin_commission_path(commission), params: { event: "accept" }
          expect(response).to redirect_to(admin_commission_path(commission))
          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end
