# frozen_string_literal: true

require 'English'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def windows? = Gem.win_platform?
def truffleruby? = RUBY_ENGINE == 'truffleruby'
def jruby? = RUBY_ENGINE == 'jruby'
def mri? = RUBY_ENGINE == 'ruby'

def ruby_command(code)
  @ruby_path ||=
    if windows?
      `where ruby`.chomp
    else
      `which ruby`.chomp
    end

  [@ruby_path, '-e', code]
end

# SimpleCov configuration
#
require 'simplecov'
require 'simplecov-lcov'
require 'simplecov-rspec'

def ci_build? = ENV.fetch('GITHUB_ACTIONS', 'false') == 'true'

if ci_build?
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
end

class String
  def with_linux_eol
    # Replace Windows style EOL (\r\n) with Unix style (\n)
    # Replace any remaining Mac style EOL (\r) with Unix style (\n)
    gsub("\r\n", "\n").gsub("\r", "\n")
  end
end

def eol = windows? ? "\r\n" : "\n"

SimpleCov::RSpec.start(list_uncovered_lines: ci_build?)

require 'ruby_git'
