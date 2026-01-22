# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "#confirmation" do
    let(:inquiry) { create(:contact_inquiry, email: "customer@example.com", name: "John Doe") }
    let(:mail) { described_class.confirmation(inquiry) }

    it "sends to the inquiry email" do
      expect(mail.to).to eq(["customer@example.com"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Thank you for contacting CMB Glass & Stone")
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end

  describe "#admin_notification" do
    let(:inquiry) { create(:contact_inquiry, email: "customer@example.com", subject: "Custom Window Question") }
    let(:mail) { described_class.admin_notification(inquiry) }

    it "includes the inquiry subject in email subject" do
      expect(mail.subject).to include("Custom Window Question")
    end

    it "includes the new inquiry prefix" do
      expect(mail.subject).to include("[New Inquiry]")
    end

    context "when inquiry has no subject" do
      let(:inquiry) { create(:contact_inquiry, subject: nil) }

      it "uses fallback subject text" do
        expect(mail.subject).to include("Contact Form Submission")
      end
    end

    context "when inquiry has blank subject" do
      let(:inquiry) { create(:contact_inquiry, subject: "") }

      it "uses fallback subject text" do
        expect(mail.subject).to include("Contact Form Submission")
      end
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end
end
