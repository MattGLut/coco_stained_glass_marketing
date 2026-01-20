# frozen_string_literal: true

# Devise configuration
# Use `rails generate devise:install` to generate this file if starting from scratch

Devise.setup do |config|
  # =============================================================================
  # Mailer Configuration
  # =============================================================================
  config.mailer_sender = ENV.fetch("DEFAULT_FROM_EMAIL", "hello@stainedglass.com")

  # Configure the class responsible to send e-mails.
  # config.mailer = 'Devise::Mailer'

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # =============================================================================
  # ORM Configuration
  # =============================================================================
  require "devise/orm/active_record"

  # =============================================================================
  # Authentication Configuration
  # =============================================================================
  
  # Case insensitive email
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # Skip session storage for specific strategies
  config.skip_session_storage = [:http_auth]

  # Stretches for bcrypt hashing (higher = more secure but slower)
  config.stretches = Rails.env.test? ? 1 : 12

  # Send a notification email when the password is changed
  config.send_password_change_notification = true

  # =============================================================================
  # Confirmable Configuration
  # =============================================================================
  
  # Time interval the user is allowed to access the website even without confirming
  config.allow_unconfirmed_access_for = 2.days

  # Time interval to reconfirm an account if the email was changed
  config.confirm_within = 3.days

  # Require email to be reconfirmed on change
  config.reconfirmable = true

  # =============================================================================
  # Rememberable Configuration
  # =============================================================================
  
  config.remember_for = 2.weeks
  config.expire_all_remember_me_on_sign_out = true
  config.extend_remember_period = false

  # =============================================================================
  # Password Validation
  # =============================================================================
  
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # =============================================================================
  # Recoverable Configuration
  # =============================================================================
  
  # Time interval you can reset your password
  config.reset_password_within = 6.hours

  # Reset password key sent to user
  config.reset_password_keys = [:email]

  # =============================================================================
  # Lockable Configuration
  # =============================================================================
  
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks account after X attempts
  # :none            = No locking
  config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking/unlocking
  config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock
  config.unlock_strategy = :both

  # Number of failed attempts before account is locked
  config.maximum_attempts = 10

  # Time interval to unlock account if unlock strategy is :time
  config.unlock_in = 1.hour

  # Warn on last attempt before locking
  config.last_attempt_warning = true

  # =============================================================================
  # Timeout Configuration
  # =============================================================================
  
  # Timeout session after inactivity
  config.timeout_in = 30.minutes

  # =============================================================================
  # Navigation Configuration
  # =============================================================================
  
  # The default HTTP method for sign out
  config.sign_out_via = :delete

  # Sign out all scopes when signing out
  config.sign_out_all_scopes = true

  # =============================================================================
  # Turbo / Hotwire Support
  # =============================================================================
  
  # Responder for Turbo/Hotwire
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # =============================================================================
  # Paranoid Mode
  # =============================================================================
  
  # When true, doesn't reveal whether an email exists in the system
  config.paranoid = true
end
