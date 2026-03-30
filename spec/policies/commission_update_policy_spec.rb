# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommissionUpdatePolicy, type: :policy do
  let(:admin) { create(:user, :admin) }
  let(:owner) { create(:user, :customer) }
  let(:other_customer) { create(:user, :customer) }
  let(:commission) { create(:commission, user: owner) }

  let(:visible_update) do
    build_stubbed(:commission_update, commission: commission, visible_to_customer: true)
  end

  let(:internal_update) do
    build_stubbed(:commission_update, commission: commission, visible_to_customer: false)
  end

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, visible_update) }

      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "as the commission owner" do
      context "with a visible update" do
        subject { described_class.new(owner, visible_update) }

        it { is_expected.to permit_action(:show) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end

      context "with an internal update" do
        subject { described_class.new(owner, internal_update) }

        it { is_expected.to forbid_action(:show) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end
    end

    context "as another customer (not the owner)" do
      subject { described_class.new(other_customer, visible_update) }

      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a guest (nil user)" do
      subject { described_class.new(nil, visible_update) }

      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "scope" do
    let!(:visible) do
      create(:commission_update, commission: commission, visible_to_customer: true)
    end
    let!(:internal) do
      create(:commission_update, commission: commission, visible_to_customer: false)
    end
    let(:other_commission) { create(:commission, user: other_customer) }
    let!(:other_update) do
      create(:commission_update, commission: other_commission, visible_to_customer: true)
    end

    it "returns all updates for admins" do
      scope = Pundit.policy_scope!(admin, CommissionUpdate)
      expect(scope).to include(visible, internal, other_update)
    end

    it "returns only visible updates on owned commissions for customers" do
      scope = Pundit.policy_scope!(owner, CommissionUpdate)
      expect(scope).to contain_exactly(visible)
    end

    it "does not include internal updates for the commission owner" do
      scope = Pundit.policy_scope!(owner, CommissionUpdate)
      expect(scope).not_to include(internal)
    end

    it "does not include other customers' updates" do
      scope = Pundit.policy_scope!(owner, CommissionUpdate)
      expect(scope).not_to include(other_update)
    end

    it "returns no updates for guests" do
      scope = Pundit.policy_scope!(nil, CommissionUpdate)
      expect(scope).to be_empty
    end
  end
end
