# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      # Dashboard is admin-only, skip Pundit checks
      # Access is already controlled by Admin::BaseController#ensure_admin_access
      skip_policy_scope

      @pending_inquiries_count = ContactInquiry.pending.count
      @active_commissions_count = Commission.active.count
      @works_count = Work.count
      @users_count = User.customer.count

      @recent_inquiries = ContactInquiry.recent.limit(5)
      @recent_commissions = Commission.recent.limit(5)
      @commissions_by_status = Commission.group(:status).count

      set_meta_tags(title: "Admin Dashboard")
    end
  end
end
