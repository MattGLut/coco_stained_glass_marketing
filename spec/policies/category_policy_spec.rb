# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryPolicy, type: :policy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:customer) { build_stubbed(:user, :customer) }
  let(:category) { build_stubbed(:category) }

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, category) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:destroy) }
    end

    context "as a customer" do
      subject { described_class.new(customer, category) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end

    context "as a guest (nil user)" do
      subject { described_class.new(nil, category) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }
    end
  end

  describe "scope" do
    it "returns all categories for any user" do
      create(:category)
      scope = Pundit.policy_scope!(admin, Category)
      expect(scope.count).to eq(Category.count)
    end
  end
end
