# frozen_string_literal: true

module Portal
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_portal_access

    layout "portal"

    private

    def ensure_portal_access
      unless current_user.portal_access?
        redirect_to root_path, alert: "You don't have access to this area."
      end
    end
  end
end
