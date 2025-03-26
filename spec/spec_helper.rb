# frozen_string_literal: true

require 'English'
require 'rspec'
require 'tempfile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Platform
def windows? = Gem.win_platform?
def mac? =RUBY_PLATFORM.include?('darwin')

# Engine
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

def run(*command)
  command = command[0] if command.size == 1 && command[0].is_a?(Array)
  ProcessExecuter.run(*command, out: StringIO.new, err: StringIO.new)
end

def status_output
  run(%w[git status -u --porcelain=v2 --renames --branch --show-stash --verbose -z]).stdout
end

def status_output_to_ruby_string
  lines = status_output.split("\u0000")
  lines.pop if lines.last && lines.last.empty?

  max_length = 70
  formatted_lines = lines.flat_map do |line|
    escaped_line = %("#{line}\\u0000")

    if escaped_line.length > max_length && (space_index = escaped_line.index(' ', max_length))
      [
        "#{escaped_line[0..space_index]}\"",
        "  \"#{escaped_line[space_index + 1..]}"
      ]
    else
      escaped_line
    end
  end

  formatted_lines.join(" \\\n  ")
end

def pbcopy(arg)
  raise 'pbcopy is only available on macOS' unless mac?

  IO.popen('pbcopy', 'w') { |io| io.puts arg }
end

# Chdir to a temporary directory and yield to the given block
#
# The temporary directory will be removed after the block is executed.
#
# @yield The block to execute in the temporary directory
# @yieldparam dir [String] The path to the temporary directory
#
# @return [Object] The return value of the given block
#
# @example
#   in_temp_dir do
#     puts Dir.pwd #=> /path/to/temp/dir
#   end
#
def in_temp_dir(&block)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir, &block)
  end
end

# Chdir to the given relative path and yield to the given block
#
# If the directory does not exist, it (and all intermediate directories) will be created.
#
# @param relative_path [String] The relative path to chdir to
# @yield The block to execute in the chdir'd directory
#
# @example
#   in_dir('foo/bar') do
#     puts Dir.pwd #=> /path/to/current/dir/foo/bar
#   end
#
def in_dir(relative_path, &)
  FileUtils.mkdir_p(relative_path)
  Dir.chdir(relative_path, &)
end

class String
  # Replace Windows style EOL (\r\n) with Unix style (\n)
  # Replace any remaining Mac style EOL (\r) with Unix style (\n)
  def with_linux_eol
    gsub("\r\n", "\n").gsub("\r", "\n")
  end
end

def eol = windows? ? "\r\n" : "\n"

SimpleCov::RSpec.start(list_uncovered_lines: ci_build?)

require 'ruby_git'
