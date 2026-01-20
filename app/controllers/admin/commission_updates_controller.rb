# frozen_string_literal: true

module Admin
  class CommissionUpdatesController < BaseController
    before_action :set_commission
    before_action :set_update, only: [:edit, :update, :destroy]

    def create
      @update = @commission.commission_updates.build(update_params)
      @update.user = current_user

      if @update.save
        redirect_to admin_commission_path(@commission), notice: "Update was posted successfully."
      else
        redirect_to admin_commission_path(@commission), alert: "Could not post update: #{@update.errors.full_messages.join(', ')}"
      end
    end

    def edit
      set_meta_tags(title: "Edit Update")
    end

    def update
      if @update.update(update_params)
        redirect_to admin_commission_path(@commission), notice: "Update was successfully edited."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @update.destroy
      redirect_to admin_commission_path(@commission), notice: "Update was deleted."
    end

    private

    def set_commission
      @commission = Commission.find(params[:commission_id])
    end

    def set_update
      @update = @commission.commission_updates.find(params[:id])
    end

    def update_params
      params.require(:commission_update).permit(
        :title, :body, :notify_customer, :visible_to_customer,
        images: []
      )
    end
  end
end
