# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ContactInquiries", type: :request do
  describe "POST /contact" do
    let(:valid_params) do
      {
        contact_inquiry: {
          name: "John Doe",
          email: "john@example.com",
          phone: "555-1234",
          subject: "Commission Inquiry",
          message: "I'd love to discuss a custom piece for my home."
        }
      }
    end

    let(:invalid_params) do
      {
        contact_inquiry: {
          name: "",
          email: "invalid",
          message: ""
        }
      }
    end

    context "with valid params" do
      it "creates a contact inquiry" do
        expect {
          post contact_inquiries_path, params: valid_params
        }.to change(ContactInquiry, :count).by(1)
      end

      it "redirects to contact page with notice" do
        post contact_inquiries_path, params: valid_params
        expect(response).to redirect_to(contact_path)
        follow_redirect!
        expect(response.body).to include("Thank you")
      end

      it "sends confirmation email" do
        expect {
          post contact_inquiries_path, params: valid_params
        }.to have_enqueued_mail(ContactMailer, :confirmation)
      end

      it "sends admin notification" do
        expect {
          post contact_inquiries_path, params: valid_params
        }.to have_enqueued_mail(ContactMailer, :admin_notification)
      end
    end

    context "with invalid params" do
      it "does not create a contact inquiry" do
        expect {
          post contact_inquiries_path, params: invalid_params
        }.not_to change(ContactInquiry, :count)
      end

      it "renders the form with errors" do
        post contact_inquiries_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
