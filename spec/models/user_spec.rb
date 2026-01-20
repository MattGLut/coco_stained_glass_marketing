# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
    end

    it "has a valid admin factory" do
      expect(build(:user, :admin)).to be_valid
    end

    it "has a valid customer factory" do
      expect(build(:user, :customer)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:commissions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:phone).is_at_most(20) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(customer: 0, admin: 1) }
  end

  describe "#full_name" do
    it "returns the combined first and last name" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.full_name).to eq("Jane Doe")
    end

    it "handles empty names" do
      user = build(:user, first_name: "", last_name: "")
      expect(user.full_name).to eq("")
    end
  end

  describe "#display_name" do
    it "returns full name when present" do
      user = build(:user, first_name: "Jane", last_name: "Doe")
      expect(user.display_name).to eq("Jane Doe")
    end

    it "returns email when name is blank" do
      user = build(:user, first_name: "", last_name: "", email: "test@example.com")
      # Note: validation would fail, but testing the method
      allow(user).to receive(:full_name).and_return("")
      expect(user.display_name).to eq("test@example.com")
    end
  end

  describe "#admin_access?" do
    it "returns true for admin users" do
      user = build(:user, :admin)
      expect(user.admin_access?).to be true
    end

    it "returns false for customer users" do
      user = build(:user, :customer)
      expect(user.admin_access?).to be false
    end
  end

  describe "#portal_access?" do
    it "returns true for customer users" do
      user = build(:user, :customer)
      expect(user.portal_access?).to be true
    end

    it "returns true for admin users" do
      user = build(:user, :admin)
      expect(user.portal_access?).to be true
    end
  end

  describe "email normalization" do
    it "downcases email before saving" do
      user = create(:user, email: "TEST@EXAMPLE.COM")
      expect(user.reload.email).to eq("test@example.com")
    end

    it "strips whitespace from email" do
      user = create(:user, email: "  test@example.com  ")
      expect(user.reload.email).to eq("test@example.com")
    end
  end

  describe "Devise modules" do
    let(:user) { create(:user) }

    it "is database authenticatable" do
      expect(user).to respond_to(:valid_password?)
    end

    it "is recoverable" do
      expect(user).to respond_to(:send_reset_password_instructions)
    end

    it "is rememberable" do
      expect(user).to respond_to(:remember_me)
    end

    it "is confirmable" do
      expect(user).to respond_to(:confirmed?)
    end

    it "is lockable" do
      expect(user).to respond_to(:lock_access!)
    end

    it "is trackable" do
      expect(user).to respond_to(:sign_in_count)
    end
  end
end
