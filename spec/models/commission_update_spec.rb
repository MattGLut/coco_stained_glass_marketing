# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommissionUpdate, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:commission_update)).to be_valid
    end

    it "has a valid internal trait" do
      expect(build(:commission_update, :internal)).to be_valid
    end

    it "has a valid silent trait" do
      expect(build(:commission_update, :silent)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:commission) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many_attached(:images) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_length_of(:body).is_at_most(5000) }
  end

  describe "scopes" do
    describe ".visible_to_customer" do
      it "returns only visible updates" do
        visible = create(:commission_update, visible_to_customer: true)
        internal = create(:commission_update, :internal)

        result = CommissionUpdate.visible_to_customer
        expect(result).to include(visible)
        expect(result).not_to include(internal)
      end
    end

    describe ".recent" do
      it "orders by created_at descending" do
        old_update = create(:commission_update, created_at: 2.days.ago)
        new_update = create(:commission_update, created_at: 1.day.ago)

        expect(CommissionUpdate.recent).to eq([new_update, old_update])
      end
    end

    describe ".chronological" do
      it "orders by created_at ascending" do
        old_update = create(:commission_update, created_at: 2.days.ago)
        new_update = create(:commission_update, created_at: 1.day.ago)

        expect(CommissionUpdate.chronological).to eq([old_update, new_update])
      end
    end
  end

  describe "#author_name" do
    it "returns user full name when user present" do
      user = build(:user, :admin, first_name: "Jane", last_name: "Admin")
      update = build(:commission_update, user: user)

      expect(update.author_name).to eq("Jane Admin")
    end

    it "returns default name when user is nil" do
      update = build(:commission_update, user: nil)
      expect(update.author_name).to eq("CMB Glass & Stone")
    end
  end

  describe "#has_images?" do
    it "returns true when images are attached" do
      update = build(:commission_update, :with_images)
      expect(update.has_images?).to be true
    end

    it "returns false when no images attached" do
      update = build(:commission_update)
      expect(update.has_images?).to be false
    end
  end

  describe "#formatted_date" do
    it "returns formatted date" do
      update = build(:commission_update, created_at: Time.zone.local(2025, 6, 15))
      expect(update.formatted_date).to eq("June 15, 2025")
    end
  end

  describe "#formatted_time" do
    it "returns formatted time" do
      update = build(:commission_update, created_at: Time.zone.local(2025, 6, 15, 14, 30))
      expect(update.formatted_time).to eq("02:30 PM")
    end
  end

  describe "callbacks" do
    describe "after_create notification" do
      context "when should notify" do
        it "sends notification email" do
          commission = create(:commission)
          expect {
            create(:commission_update,
              commission: commission,
              notify_customer: true,
              visible_to_customer: true
            )
          }.to have_enqueued_mail(CommissionMailer, :update_notification)
        end
      end

      context "when should not notify" do
        it "does not send notification for internal updates" do
          expect {
            create(:commission_update, :internal)
          }.not_to have_enqueued_mail(CommissionMailer, :update_notification)
        end

        it "does not send notification when notify_customer is false" do
          expect {
            create(:commission_update, :silent)
          }.not_to have_enqueued_mail(CommissionMailer, :update_notification)
        end
      end
    end
  end
end
