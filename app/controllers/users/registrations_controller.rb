# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    portal_dashboard_path
  end

  def after_update_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      portal_dashboard_path
    end
  end
end
