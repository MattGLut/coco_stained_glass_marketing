# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update]

    def index
      @users = User.order(created_at: :desc)

      if params[:role].present?
        @users = @users.where(role: params[:role])
      end

      set_meta_tags(title: "Manage Users")
    end

    def show
      @commissions = @user.commissions.recent

      set_meta_tags(title: @user.full_name)
    end

    def edit
      set_meta_tags(title: "Edit: #{@user.full_name}")
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :role)
    end
  end
end
