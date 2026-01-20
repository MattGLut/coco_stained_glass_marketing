# frozen_string_literal: true

# SendGrid configuration for Action Mailer
# This initializer sets up SMTP settings for SendGrid

# Skip during Docker build (SECRET_KEY_BASE_DUMMY is set during asset precompilation)
return if ENV["SECRET_KEY_BASE_DUMMY"].present?

if ENV["SENDGRID_API_KEY"].present?
  ActionMailer::Base.smtp_settings = {
    user_name: "apikey", # This is literally the string "apikey", not your API key
    password: ENV["SENDGRID_API_KEY"],
    domain: ENV.fetch("SENDGRID_DOMAIN", "stainedglass.com"),
    address: "smtp.sendgrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
