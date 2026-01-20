# frozen_string_literal: true

require "webmock/rspec"

# Allow localhost connections for Capybara
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    "chromedriver.storage.googleapis.com",
    "googlechromelabs.github.io"
  ]
)
