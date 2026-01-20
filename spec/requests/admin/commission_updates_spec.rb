# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::CommissionUpdates", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:commission) { create(:commission, :in_progress) }

  describe "authentication" do
    it "redirects to sign in when not authenticated" do
      post admin_commission_updates_path(commission)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects customers to root with alert" do
      sign_in customer
      post admin_commission_updates_path(commission)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end
  end

  context "when signed in as admin" do
    before { sign_in admin }

    describe "POST /admin/commissions/:commission_id/updates" do
      let(:valid_params) do
        {
          commission_update: {
            title: "Progress Update",
            body: "Work is progressing well on your commission.",
            notify_customer: true,
            visible_to_customer: true
          }
        }
      end

      let(:invalid_params) do
        {
          commission_update: {
            title: "",
            body: ""
          }
        }
      end

      context "with valid params" do
        it "creates a new commission update" do
          expect {
            post admin_commission_updates_path(commission), params: valid_params
          }.to change(CommissionUpdate, :count).by(1)
        end

        it "associates the update with the current admin user" do
          post admin_commission_updates_path(commission), params: valid_params
          expect(CommissionUpdate.last.user).to eq(admin)
        end

        it "redirects to the commission page" do
          post admin_commission_updates_path(commission), params: valid_params
          expect(response).to redirect_to(admin_commission_path(commission))
        end

        it "sets a success notice" do
          post admin_commission_updates_path(commission), params: valid_params
          expect(flash[:notice]).to include("successfully")
        end
      end

      context "with invalid params" do
        it "does not create an update" do
          expect {
            post admin_commission_updates_path(commission), params: invalid_params
          }.not_to change(CommissionUpdate, :count)
        end

        it "redirects with alert message" do
          post admin_commission_updates_path(commission), params: invalid_params
          expect(response).to redirect_to(admin_commission_path(commission))
          expect(flash[:alert]).to be_present
        end
      end
    end

    describe "GET /admin/commissions/:commission_id/updates/:id/edit" do
      let(:update) { create(:commission_update, commission: commission, user: admin) }

      it "returns success" do
        get edit_admin_commission_update_path(commission, update)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /admin/commissions/:commission_id/updates/:id" do
      let(:update) { create(:commission_update, commission: commission, user: admin, title: "Original Title") }

      context "with valid params" do
        it "updates the commission update" do
          patch admin_commission_update_path(commission, update), params: { commission_update: { title: "Updated Title" } }
          expect(update.reload.title).to eq("Updated Title")
        end

        it "redirects to the commission page" do
          patch admin_commission_update_path(commission, update), params: { commission_update: { title: "Updated Title" } }
          expect(response).to redirect_to(admin_commission_path(commission))
        end

        it "sets a success notice" do
          patch admin_commission_update_path(commission, update), params: { commission_update: { title: "Updated Title" } }
          expect(flash[:notice]).to include("successfully")
        end
      end

      context "with invalid params" do
        it "renders the form with errors" do
          patch admin_commission_update_path(commission, update), params: { commission_update: { title: "", body: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /admin/commissions/:commission_id/updates/:id" do
      let!(:update) { create(:commission_update, commission: commission, user: admin) }

      it "deletes the commission update" do
        expect {
          delete admin_commission_update_path(commission, update)
        }.to change(CommissionUpdate, :count).by(-1)
      end

      it "redirects to the commission page" do
        delete admin_commission_update_path(commission, update)
        expect(response).to redirect_to(admin_commission_path(commission))
      end

      it "sets a success notice" do
        delete admin_commission_update_path(commission, update)
        expect(flash[:notice]).to include("deleted")
      end
    end
  end
end
