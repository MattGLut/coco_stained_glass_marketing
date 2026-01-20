# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommissionMailer, type: :mailer do
  let(:customer) { create(:user, :customer, email: "customer@example.com") }
  let(:commission) { create(:commission, user: customer, title: "Custom Stained Glass Window") }

  describe "#update_notification" do
    let(:commission_update) { create(:commission_update, commission: commission, title: "Progress Update") }
    let(:mail) { described_class.update_notification(commission_update) }

    it "sends to the customer email" do
      expect(mail.to).to eq(["customer@example.com"])
    end

    it "includes the commission title in subject" do
      expect(mail.subject).to include("Custom Stained Glass Window")
    end

    it "has update prefix in subject" do
      expect(mail.subject).to include("Update on your commission")
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end

  describe "#status_changed" do
    let(:mail) { described_class.status_changed(commission, "inquiry") }

    it "sends to the customer email" do
      expect(mail.to).to eq(["customer@example.com"])
    end

    it "includes status update in subject" do
      expect(mail.subject).to include("status has been updated")
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end

  describe "#quote_provided" do
    let(:commission) { create(:commission, :with_quote, user: customer, title: "Quoted Window") }
    let(:mail) { described_class.quote_provided(commission) }

    it "sends to the customer email" do
      expect(mail.to).to eq(["customer@example.com"])
    end

    it "has quote-related subject" do
      expect(mail.subject).to include("Your quote is ready")
    end

    it "includes commission title in subject" do
      expect(mail.subject).to include("Quoted Window")
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end

  describe "#commission_completed" do
    let(:commission) { create(:commission, :completed, user: customer, title: "Completed Window") }
    let(:mail) { described_class.commission_completed(commission) }

    it "sends to the customer email" do
      expect(mail.to).to eq(["customer@example.com"])
    end

    it "has completion subject" do
      expect(mail.subject).to include("commission is complete")
    end

    it "includes commission title in subject" do
      expect(mail.subject).to include("Completed Window")
    end

    it "renders the body" do
      expect(mail.body.encoded).to be_present
    end
  end
end
