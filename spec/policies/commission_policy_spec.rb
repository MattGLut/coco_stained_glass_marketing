# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommissionPolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:owner) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:commission) { build_stubbed(:commission, user: owner) }

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, commission) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:transition) }
    end

    context "as the commission owner" do
      subject { described_class.new(owner, commission) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:transition) }
    end

    context "as another customer (not the owner)" do
      subject { described_class.new(other_customer, commission) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:transition) }
    end

    context "as a guest (nil user)" do
      subject { described_class.new(nil, commission) }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:transition) }
    end
  end

  describe "scope" do
    let!(:owner_commission) { create(:commission, user: owner) }
    let!(:other_commission) { create(:commission, user: other_customer) }

    it "returns all commissions for admins" do
      scope = Pundit.policy_scope!(admin, Commission)
      expect(scope).to include(owner_commission, other_commission)
    end

    it "returns only owned commissions for a customer" do
      scope = Pundit.policy_scope!(owner, Commission)
      expect(scope).to contain_exactly(owner_commission)
    end

    it "returns no commissions for guests" do
      scope = Pundit.policy_scope!(nil, Commission)
      expect(scope).to be_empty
    end
  end
end
