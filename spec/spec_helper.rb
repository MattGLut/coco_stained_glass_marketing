# frozen_string_literal: true

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

RSpec.configure do |config|
  # rspec-expectations config
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Allows RSpec to persist some state between runs
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed

  # Focus on specific tests with `fit`, `fdescribe`, `fcontext`
  config.filter_run_when_matching :focus

  # Print slowest examples when running full suite
  config.profile_examples = 10 if config.files_to_run.length > 50
end
