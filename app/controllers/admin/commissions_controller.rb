# frozen_string_literal: true

module Admin
  class CommissionsController < BaseController
    before_action :set_commission, only: [:show, :edit, :update, :destroy, :transition]

    def index
      @commissions = policy_scope(Commission).includes(:user).recent

      if params[:status].present?
        @commissions = @commissions.by_status(params[:status])
      end

      set_meta_tags(title: "Manage Commissions")
    end

    def show
      authorize @commission
      @updates = @commission.commission_updates.recent
      @new_update = @commission.commission_updates.build

      set_meta_tags(title: @commission.title)
    end

    def new
      @commission = Commission.new
      authorize @commission
      @users = User.customer.order(:last_name, :first_name)

      set_meta_tags(title: "New Commission")
    end

    def create
      @commission = Commission.new(commission_params)
      authorize @commission
      @users = User.customer.order(:last_name, :first_name)

      if @commission.save
        redirect_to admin_commission_path(@commission), notice: "Commission was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @commission
      @users = User.customer.order(:last_name, :first_name)

      set_meta_tags(title: "Edit: #{@commission.title}")
    end

    def update
      authorize @commission
      @users = User.customer.order(:last_name, :first_name)

      if @commission.update(commission_params)
        redirect_to admin_commission_path(@commission), notice: "Commission was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @commission
      @commission.destroy
      redirect_to admin_commissions_path, notice: "Commission was successfully deleted."
    end

    def transition
      authorize @commission
      event = params[:event]&.to_sym

      if @commission.aasm.events.map(&:name).include?(event)
        if @commission.send("may_#{event}?") && @commission.send("#{event}!")
          redirect_to admin_commission_path(@commission), notice: "Status updated to #{@commission.status_label}."
        else
          redirect_to admin_commission_path(@commission), alert: "Could not perform this action."
        end
      else
        redirect_to admin_commission_path(@commission), alert: "Invalid action."
      end
    end

    private

    def set_commission
      @commission = Commission.find(params[:id])
    end

    def commission_params
      params.require(:commission).permit(
        :user_id, :title, :description, :customer_notes, :internal_notes,
        :estimated_start_date, :estimated_completion_date,
        :estimated_price, :final_price, :deposit_amount, :deposit_paid,
        :dimensions, :location,
        reference_images: [],
        progress_images: [],
        final_images: []
      )
    end
  end
end
