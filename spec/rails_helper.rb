# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "pundit/rspec"

# Add additional requires below this line
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # =============================================================================
  # Database & Fixtures
  # =============================================================================

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Include FactoryBot methods
  config.include FactoryBot::Syntax::Methods

  # =============================================================================
  # Test Type Inference
  # =============================================================================

  # Infer spec type from file location
  config.infer_spec_type_from_file_location!

  # Filter Rails gems from backtraces
  config.filter_rails_from_backtrace!

  # =============================================================================
  # Devise Test Helpers
  # =============================================================================

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # =============================================================================
  # System Tests Configuration
  # =============================================================================

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  # =============================================================================
  # Pundit Authorization Helpers
  # =============================================================================

  config.include Pundit::Authorization, type: :controller

  # =============================================================================
  # Active Storage Test Cleanup
  # =============================================================================

  config.after(:suite) do
    FileUtils.rm_rf(ActiveStorage::Blob.service.root) if defined?(ActiveStorage)
  end
end

# =============================================================================
# Shoulda Matchers Configuration
# =============================================================================

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
