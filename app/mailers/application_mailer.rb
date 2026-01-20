# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("DEFAULT_FROM_EMAIL", "hello@stainedglass.com") }
  layout "mailer"

  private

  def admin_email
    ENV.fetch("ADMIN_EMAIL", "coco@stainedglass.com")
  end
end
