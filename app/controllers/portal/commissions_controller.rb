# frozen_string_literal: true

module Portal
  class CommissionsController < BaseController
    before_action :set_commission, only: [:show]

    def index
      @commissions = policy_scope(Commission).recent

      set_meta_tags(title: "My Commissions")
    end

    def show
      authorize @commission
      @updates = @commission.visible_updates

      set_meta_tags(title: @commission.title)
    end

    private

    def set_commission
      @commission = policy_scope(Commission).find(params[:id])
    end
  end
end
