# frozen_string_literal: true

module SystemHelpers
  # Sign in via the UI (for system tests)
  def ui_sign_in(user, password: "password123")
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Sign in"
  end

  # Wait for Turbo to finish loading
  def wait_for_turbo
    return unless page.has_css?("[data-turbo-preview]", wait: 0.1)

    page.has_no_css?("[data-turbo-preview]", wait: 5)
  end

  # Take a screenshot with a descriptive name (useful for debugging)
  def screenshot!(name = nil)
    name ||= "screenshot_#{Time.current.to_i}"
    page.save_screenshot("tmp/screenshots/#{name}.png")
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
