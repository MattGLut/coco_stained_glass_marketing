# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]

  # Only enable in production by default
  config.enabled = Rails.env.production? && ENV["ROLLBAR_ACCESS_TOKEN"].present?

  # Environment name
  config.environment = ENV.fetch("ROLLBAR_ENV", Rails.env)

  # Add custom data to be sent with every error
  config.custom_data_method = lambda do |_message, _exception, _request, _context|
    {
      application: "stained_glass_marketing",
      rails_version: Rails::VERSION::STRING
    }
  end

  # Filter sensitive parameters
  config.scrub_fields = [
    :passwd,
    :password,
    :password_confirmation,
    :secret,
    :confirm_password,
    :secret_token,
    :api_key,
    :access_token,
    :accessToken,
    :stripe_publishable_key,
    :stripe_secret_key
  ]

  # Ignore common bot/scan errors
  config.exception_level_filters.merge!(
    "ActionController::RoutingError" => "ignore",
    "ActionController::InvalidAuthenticityToken" => "ignore"
  )

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object. Override this for custom user info.
  config.person_method = "current_user"
  config.person_id_method = "id"
  config.person_username_method = "email"
  config.person_email_method = "email"
end
