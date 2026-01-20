# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin_access

    layout "admin"

    private

    def ensure_admin_access
      unless current_user.admin_access?
        redirect_to root_path, alert: "You must be an administrator to access this area."
      end
    end

    def skip_pundit?
      true
    end
  end
end
