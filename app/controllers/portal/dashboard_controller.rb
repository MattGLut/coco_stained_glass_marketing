# frozen_string_literal: true

module Portal
  class DashboardController < BaseController
    def index
      @commissions = policy_scope(Commission).recent
      @active_commissions = @commissions.active
      @completed_commissions = @commissions.where(status: [:completed, :delivered])

      set_meta_tags(title: "My Dashboard")
    end
  end
end
