# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::ContactInquiries", type: :request do
  describe "authentication" do
    context "when not signed in" do
      it "redirects to sign in" do
        get admin_contact_inquiries_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as customer" do
      let(:customer) { create(:user, :customer) }

      before { sign_in customer }

      it "redirects to root with alert" do
        get admin_contact_inquiries_path
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  context "when signed in as admin" do
    let(:admin) { create(:user, :admin) }

    before { sign_in admin }

    describe "GET /admin/contact_inquiries" do
      let!(:pending_inquiry) { create(:contact_inquiry, name: "Pending Person", status: :pending) }
      let!(:responded_inquiry) { create(:contact_inquiry, :responded, name: "Responded Person") }
      let!(:archived_inquiry) { create(:contact_inquiry, :archived, name: "Archived Person") }

      it "returns success" do
        get admin_contact_inquiries_path
        expect(response).to have_http_status(:success)
      end

      it "displays all inquiries" do
        get admin_contact_inquiries_path
        expect(response.body).to include("Pending Person")
        expect(response.body).to include("Responded Person")
        expect(response.body).to include("Archived Person")
      end

      it "filters by pending status" do
        get admin_contact_inquiries_path(status: "pending")
        expect(response.body).to include("Pending Person")
        expect(response.body).not_to include("Responded Person")
      end

      it "filters by responded status" do
        get admin_contact_inquiries_path(status: "responded")
        expect(response.body).to include("Responded Person")
        expect(response.body).not_to include("Archived Person")
      end

      it "filters by archived status" do
        get admin_contact_inquiries_path(status: "archived")
        expect(response.body).to include("Archived Person")
        expect(response.body).not_to include("Responded Person")
      end
    end

    describe "GET /admin/contact_inquiries/:id" do
      let(:inquiry) { create(:contact_inquiry, name: "John Doe", message: "Test message content") }

      it "returns success" do
        get admin_contact_inquiry_path(inquiry)
        expect(response).to have_http_status(:success)
      end

      it "displays inquiry details" do
        get admin_contact_inquiry_path(inquiry)
        expect(response.body).to include("John Doe")
        expect(response.body).to include("Test message content")
      end
    end

    describe "PATCH /admin/contact_inquiries/:id" do
      let(:inquiry) { create(:contact_inquiry) }

      context "with valid params" do
        it "updates admin notes" do
          patch admin_contact_inquiry_path(inquiry), params: {
            contact_inquiry: { admin_notes: "Follow up next week" }
          }
          expect(inquiry.reload.admin_notes).to eq("Follow up next week")
        end

        it "redirects to inquiry page" do
          patch admin_contact_inquiry_path(inquiry), params: {
            contact_inquiry: { admin_notes: "Notes" }
          }
          expect(response).to redirect_to(admin_contact_inquiry_path(inquiry))
        end
      end
    end

    describe "DELETE /admin/contact_inquiries/:id" do
      let!(:inquiry) { create(:contact_inquiry) }

      it "deletes the inquiry" do
        expect {
          delete admin_contact_inquiry_path(inquiry)
        }.to change(ContactInquiry, :count).by(-1)
      end

      it "redirects to inquiries index" do
        delete admin_contact_inquiry_path(inquiry)
        expect(response).to redirect_to(admin_contact_inquiries_path)
      end
    end

    describe "PATCH /admin/contact_inquiries/:id/mark_responded" do
      let(:inquiry) { create(:contact_inquiry, status: :pending) }

      it "marks the inquiry as responded" do
        patch mark_responded_admin_contact_inquiry_path(inquiry)
        expect(inquiry.reload.status).to eq("responded")
      end

      it "sets responded_at timestamp" do
        patch mark_responded_admin_contact_inquiry_path(inquiry)
        expect(inquiry.reload.responded_at).to be_present
        expect(inquiry.reload.responded_at).to be_within(5.seconds).of(Time.current)
      end

      it "redirects to inquiry page" do
        patch mark_responded_admin_contact_inquiry_path(inquiry)
        expect(response).to redirect_to(admin_contact_inquiry_path(inquiry))
      end
    end

    describe "PATCH /admin/contact_inquiries/:id/archive" do
      let(:inquiry) { create(:contact_inquiry, status: :pending) }

      it "archives the inquiry" do
        patch archive_admin_contact_inquiry_path(inquiry)
        expect(inquiry.reload.status).to eq("archived")
      end

      it "redirects to inquiries index" do
        patch archive_admin_contact_inquiry_path(inquiry)
        expect(response).to redirect_to(admin_contact_inquiries_path)
      end
    end
  end
end
