# frozen_string_literal: true

# SendGrid configuration for Action Mailer
# This initializer sets up SMTP settings for SendGrid

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
