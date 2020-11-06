# frozen_string_literal: true

require 'simplecov'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Setup simplecov
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start

SimpleCov.at_exit do
  unless RSpec.configuration.dry_run?
    SimpleCov.result.format!
    if SimpleCov.result.covered_percent < 100
      warn 'FAIL: RSpec Test coverage fell below 100%'
      exit 1
    end
  end
end

require 'ruby_git'
