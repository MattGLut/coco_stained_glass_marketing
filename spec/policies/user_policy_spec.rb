# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:customer) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, customer) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
    end

    context "admin destroying another user" do
      subject { described_class.new(admin, customer) }

      it { is_expected.to permit_action(:destroy) }
    end

    context "admin destroying themselves" do
      subject { described_class.new(admin, admin) }

      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a customer viewing/editing themselves" do
      subject { described_class.new(customer, customer) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a customer viewing another user" do
      subject { described_class.new(customer, other_customer) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a guest (nil user)" do
      subject { described_class.new(nil, customer) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "scope" do
    before do
      admin
      customer
      other_customer
    end

    it "returns all users for admins" do
      scope = Pundit.policy_scope!(admin, User)
      expect(scope).to include(admin, customer, other_customer)
    end

    it "returns only the user themselves for customers" do
      scope = Pundit.policy_scope!(customer, User)
      expect(scope).to contain_exactly(customer)
    end

    it "returns no users for guests" do
      scope = Pundit.policy_scope!(nil, User)
      expect(scope).to be_empty
    end
  end
end
