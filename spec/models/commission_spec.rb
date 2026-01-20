# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commission, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:commission)).to be_valid
    end

    it "has valid trait factories" do
      expect(build(:commission, :with_quote)).to be_valid
      expect(build(:commission, :accepted)).to be_valid
      expect(build(:commission, :in_progress)).to be_valid
      expect(build(:commission, :completed)).to be_valid
      expect(build(:commission, :delivered)).to be_valid
      expect(build(:commission, :cancelled)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:commission_updates).dependent(:destroy) }
    it { is_expected.to have_many_attached(:reference_images) }
    it { is_expected.to have_many_attached(:progress_images) }
    it { is_expected.to have_many_attached(:final_images) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(200) }
    it { is_expected.to validate_length_of(:description).is_at_most(5000) }
    it { is_expected.to validate_length_of(:customer_notes).is_at_most(2000) }
    it { is_expected.to validate_length_of(:internal_notes).is_at_most(5000) }
    it { is_expected.to validate_numericality_of(:estimated_price).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:final_price).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:deposit_amount).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe "AASM state machine" do
    describe "initial state" do
      it "starts in inquiry state" do
        commission = build(:commission)
        expect(commission.status).to eq("inquiry")
        expect(commission).to be_inquiry
      end
    end

    describe "transitions" do
      describe "#provide_quote" do
        it "transitions from inquiry to quoted" do
          commission = create(:commission, status: "inquiry")
          expect { commission.provide_quote! }.to change { commission.status }.from("inquiry").to("quoted")
        end

        it "does not allow from other states" do
          commission = create(:commission, :in_progress)
          expect { commission.provide_quote! }.to raise_error(AASM::InvalidTransition)
        end
      end

      describe "#accept" do
        it "transitions from quoted to accepted" do
          commission = create(:commission, :with_quote)
          expect { commission.accept! }.to change { commission.status }.from("quoted").to("accepted")
        end
      end

      describe "#receive_deposit" do
        it "transitions from accepted to deposit_received" do
          commission = create(:commission, :accepted)
          expect { commission.receive_deposit! }.to change { commission.status }.from("accepted").to("deposit_received")
        end

        it "sets deposit_paid to true" do
          commission = create(:commission, :accepted)
          commission.receive_deposit!
          expect(commission.deposit_paid).to be true
          expect(commission.deposit_paid_at).to eq(Date.current)
        end
      end

      describe "#start_work" do
        it "transitions from accepted to in_progress" do
          commission = create(:commission, :accepted)
          expect { commission.start_work! }.to change { commission.status }.to("in_progress")
        end

        it "transitions from deposit_received to in_progress" do
          commission = create(:commission, :deposit_received)
          expect { commission.start_work! }.to change { commission.status }.to("in_progress")
        end

        it "sets actual_start_date" do
          commission = create(:commission, :accepted, actual_start_date: nil)
          commission.start_work!
          expect(commission.actual_start_date).to eq(Date.current)
        end
      end

      describe "#submit_for_review" do
        it "transitions from in_progress to review" do
          commission = create(:commission, :in_progress)
          expect { commission.submit_for_review! }.to change { commission.status }.to("review")
        end
      end

      describe "#request_changes" do
        it "transitions from review back to in_progress" do
          commission = create(:commission, :in_progress)
          commission.submit_for_review!
          expect { commission.request_changes! }.to change { commission.status }.to("in_progress")
        end
      end

      describe "#complete" do
        it "transitions from in_progress to completed" do
          commission = create(:commission, :in_progress)
          expect { commission.complete! }.to change { commission.status }.to("completed")
        end

        it "sets actual_completion_date" do
          commission = create(:commission, :in_progress, actual_completion_date: nil)
          commission.complete!
          expect(commission.actual_completion_date).to eq(Date.current)
        end
      end

      describe "#deliver" do
        it "transitions from completed to delivered" do
          commission = create(:commission, :completed)
          expect { commission.deliver! }.to change { commission.status }.to("delivered")
        end

        it "sets delivered_at date" do
          commission = create(:commission, :completed)
          commission.deliver!
          expect(commission.delivered_at).to eq(Date.current)
        end
      end

      describe "#cancel" do
        it "can cancel from various states" do
          %w[inquiry quoted accepted deposit_received in_progress].each do |state|
            commission = create(:commission, status: state)
            expect { commission.cancel! }.to change { commission.status }.to("cancelled")
          end
        end
      end

      describe "#reopen" do
        it "transitions from cancelled to inquiry" do
          commission = create(:commission, :cancelled)
          expect { commission.reopen! }.to change { commission.status }.to("inquiry")
        end
      end
    end
  end

  describe "scopes" do
    describe ".active" do
      it "excludes delivered and cancelled commissions" do
        active = create(:commission, :in_progress)
        delivered = create(:commission, :delivered)
        cancelled = create(:commission, :cancelled)

        result = Commission.active
        expect(result).to include(active)
        expect(result).not_to include(delivered, cancelled)
      end
    end

    describe ".for_user" do
      it "returns commissions for specific user" do
        user = create(:user)
        user_commission = create(:commission, user: user)
        other_commission = create(:commission)

        expect(Commission.for_user(user)).to include(user_commission)
        expect(Commission.for_user(user)).not_to include(other_commission)
      end
    end
  end

  describe "#progress_percentage" do
    it "returns correct percentage for each status" do
      expect(build(:commission, status: "inquiry").progress_percentage).to eq(5)
      expect(build(:commission, status: "quoted").progress_percentage).to eq(15)
      expect(build(:commission, status: "accepted").progress_percentage).to eq(25)
      expect(build(:commission, status: "deposit_received").progress_percentage).to eq(35)
      expect(build(:commission, status: "in_progress").progress_percentage).to eq(60)
      expect(build(:commission, status: "review").progress_percentage).to eq(80)
      expect(build(:commission, status: "completed").progress_percentage).to eq(95)
      expect(build(:commission, status: "delivered").progress_percentage).to eq(100)
    end
  end

  describe "#overdue?" do
    it "returns true when past estimated completion and not done" do
      commission = build(:commission, :in_progress, estimated_completion_date: 1.week.ago.to_date)
      expect(commission.overdue?).to be true
    end

    it "returns false when completed" do
      commission = build(:commission, :completed, estimated_completion_date: 1.week.ago.to_date)
      expect(commission.overdue?).to be false
    end

    it "returns false when no estimated date" do
      commission = build(:commission, :in_progress, estimated_completion_date: nil)
      expect(commission.overdue?).to be false
    end
  end

  describe "#deposit_outstanding?" do
    it "returns true when deposit not paid" do
      commission = build(:commission, :accepted, deposit_amount: 500, deposit_paid: false)
      expect(commission.deposit_outstanding?).to be true
    end

    it "returns false when deposit paid" do
      commission = build(:commission, :deposit_received)
      expect(commission.deposit_outstanding?).to be false
    end

    it "returns false when no deposit amount" do
      commission = build(:commission, deposit_amount: nil)
      expect(commission.deposit_outstanding?).to be false
    end
  end
end
