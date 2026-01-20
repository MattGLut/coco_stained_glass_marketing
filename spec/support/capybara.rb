# frozen_string_literal: true

require "capybara/rspec"

Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.default_normalize_ws = true
  config.server = :puma, { Silent: true }
end

# Register Chrome headless driver for JS tests
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1920,1080")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Default JS driver
Capybara.javascript_driver = :selenium_chrome_headless
