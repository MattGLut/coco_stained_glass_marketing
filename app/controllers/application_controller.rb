# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps,
  # CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pundit: ensure authorization is called (disabled for now - enable per-controller as needed)
  # after_action :verify_authorized, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Pundit: handle authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Devise: configure permitted parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      portal_dashboard_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def skip_pundit?
    devise_controller? || 
      controller_name == "pages" || 
      controller_name == "health" ||
      self.class.name.start_with?("Rails::")
  end

  # SEO helper for meta tags
  def set_meta_tags(options = {})
    @page_title = options[:title]
    @page_description = options[:description]
    @page_image = options[:image]
    @page_keywords = options[:keywords]
  end
end
