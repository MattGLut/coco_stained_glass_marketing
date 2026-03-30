# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkPolicy, type: :policy do
  let(:admin) { build_stubbed(:user, :admin) }
  let(:customer) { build_stubbed(:user, :customer) }
  let(:published_work) { build_stubbed(:work, published: true) }
  let(:draft_work) { build_stubbed(:work, published: false) }

  describe "permissions" do
    context "as an admin" do
      subject { described_class.new(admin, published_work) }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:publish) }
      it { is_expected.to permit_action(:unpublish) }
      it { is_expected.to permit_action(:feature) }
      it { is_expected.to permit_action(:unfeature) }
      it { is_expected.to permit_action(:remove_image) }
      it { is_expected.to permit_action(:update_positions) }
    end

    context "admin viewing a draft work" do
      subject { described_class.new(admin, draft_work) }

      it { is_expected.to permit_action(:show) }
    end

    context "as a customer" do
      context "viewing a published work" do
        subject { described_class.new(customer, published_work) }

        it { is_expected.to permit_action(:index) }
        it { is_expected.to permit_action(:show) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
        it { is_expected.to forbid_action(:publish) }
        it { is_expected.to forbid_action(:unpublish) }
        it { is_expected.to forbid_action(:feature) }
        it { is_expected.to forbid_action(:unfeature) }
        it { is_expected.to forbid_action(:remove_image) }
        it { is_expected.to forbid_action(:update_positions) }
      end

      context "viewing a draft work" do
        subject { described_class.new(customer, draft_work) }

        it { is_expected.to forbid_action(:show) }
      end
    end

    context "as a guest (nil user)" do
      context "viewing a published work" do
        subject { described_class.new(nil, published_work) }

        it { is_expected.to permit_action(:index) }
        it { is_expected.to permit_action(:show) }
        it { is_expected.to forbid_action(:create) }
        it { is_expected.to forbid_action(:update) }
        it { is_expected.to forbid_action(:destroy) }
      end

      context "viewing a draft work" do
        subject { described_class.new(nil, draft_work) }

        it { is_expected.to forbid_action(:show) }
      end
    end
  end

  describe "scope" do
    let!(:published) { create(:work, published: true) }
    let!(:draft) { create(:work, published: false) }

    it "returns all works for admins" do
      admin_user = create(:user, :admin)
      scope = Pundit.policy_scope!(admin_user, Work)
      expect(scope).to include(published, draft)
    end

    it "returns only published works for customers" do
      customer_user = create(:user, :customer)
      scope = Pundit.policy_scope!(customer_user, Work)
      expect(scope).to include(published)
      expect(scope).not_to include(draft)
    end

    it "returns only published works for guests" do
      scope = Pundit.policy_scope!(nil, Work)
      expect(scope).to include(published)
      expect(scope).not_to include(draft)
    end
  end
end
