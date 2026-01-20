# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Lint factories before running tests (optional, can be slow)
  config.before(:suite) do
    if ENV["FACTORY_LINT"] == "true"
      DatabaseCleaner.cleaning do
        FactoryBot.lint(traits: true)
      end
    end
  end
end
