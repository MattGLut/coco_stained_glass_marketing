# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactInquiryPolicy, type: :policy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:customer) { build_stubbed(:user, :customer) }
  let(:inquiry) { build_stubbed(:contact_inquiry) }

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, inquiry) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:mark_responded) }
      it { is_expected.to permit_action(:archive) }
    end

    context "as a customer" do
      subject { described_class.new(customer, inquiry) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:mark_responded) }
      it { is_expected.to forbid_action(:archive) }
    end

    context "as a guest (nil user)" do
      subject { described_class.new(nil, inquiry) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:mark_responded) }
      it { is_expected.to forbid_action(:archive) }
    end
  end

  describe "scope" do
    before { create(:contact_inquiry) }

    it "returns all inquiries for admins" do
      admin_user = create(:user, :admin)
      scope = Pundit.policy_scope!(admin_user, ContactInquiry)
      expect(scope.count).to eq(ContactInquiry.count)
    end

    it "returns no inquiries for customers" do
      customer_user = create(:user, :customer)
      scope = Pundit.policy_scope!(customer_user, ContactInquiry)
      expect(scope).to be_empty
    end

    it "returns no inquiries for guests" do
      scope = Pundit.policy_scope!(nil, ContactInquiry)
      expect(scope).to be_empty
    end
  end
end
