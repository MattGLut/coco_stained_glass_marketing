# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationPolicy, type: :policy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:customer) { build_stubbed(:user, :customer) }
  let(:record) { build_stubbed(:work) }

  describe "default permissions (deny-all)" do
    subject { described_class.new(user, record) }

    context "as an admin" do
      let(:user) { admin }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a customer" do
      let(:user) { customer }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:new) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:edit) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a guest (nil user)" do
      let(:user) { nil }

      it { is_expected.to forbid_action(:index) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "helper methods" do
    describe "#admin?" do
      it "returns true for admin users" do
        policy = described_class.new(admin, record)
        expect(policy.send(:admin?)).to be true
      end

      it "returns false for customer users" do
        policy = described_class.new(customer, record)
        expect(policy.send(:admin?)).to be false
      end

      it "returns false for nil user" do
        policy = described_class.new(nil, record)
        expect(policy.send(:admin?)).to be_falsey
      end
    end

    describe "#customer?" do
      it "returns true for customer users" do
        policy = described_class.new(customer, record)
        expect(policy.send(:customer?)).to be true
      end

      it "returns false for admin users" do
        policy = described_class.new(admin, record)
        expect(policy.send(:customer?)).to be false
      end
    end

    describe "#logged_in?" do
      it "returns true when user is present" do
        policy = described_class.new(customer, record)
        expect(policy.send(:logged_in?)).to be true
      end

      it "returns false when user is nil" do
        policy = described_class.new(nil, record)
        expect(policy.send(:logged_in?)).to be false
      end
    end

    describe "#owned_by_user?" do
      it "returns true when record belongs to user" do
        commission = build_stubbed(:commission, user: customer)
        policy = described_class.new(customer, commission)
        expect(policy.send(:owned_by_user?)).to be true
      end

      it "returns false when record belongs to another user" do
        other = build_stubbed(:user, :customer)
        commission = build_stubbed(:commission, user: other)
        policy = described_class.new(customer, commission)
        expect(policy.send(:owned_by_user?)).to be false
      end

      it "returns false when record has no user_id" do
        policy = described_class.new(customer, build_stubbed(:category))
        expect(policy.send(:owned_by_user?)).to be false
      end
    end
  end

  describe ApplicationPolicy::Scope do
    describe "#resolve" do
      it "returns no records by default" do
        create(:work, published: true)
        scope = described_class.new(admin, Work.all)
        expect(scope.resolve).to be_empty
      end
    end
  end
end
