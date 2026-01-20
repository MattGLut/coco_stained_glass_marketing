# frozen_string_literal: true

module Portal
  class CommissionsController < BaseController
    before_action :set_commission, only: [:show]

    def index
      @commissions = current_user.commissions.recent

      set_meta_tags(title: "My Commissions")
    end

    def show
      @updates = @commission.visible_updates

      set_meta_tags(title: @commission.title)
    end

    private

    def set_commission
      @commission = current_user.commissions.find(params[:id])
    end
  end
end
