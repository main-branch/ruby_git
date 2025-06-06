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
  ProcessExecuter.run_with_capture(*command)
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

class Array
  # Return a new array with old_value replaced with new_value
  #
  # @example
  #   array = [1, 2, 3]
  #   array.sub(2, 4) #=> [1, 4, 3]
  #
  # @param old_value [Object] The value to replace
  # @param new_value [Object] The value to replace with
  #
  # @return [Array] A new array with the replaced value
  #
  def sub(old_value, new_value)
    dup.tap do |new_array|
      if (i = new_array.index(old_value))
        new_array[i] = new_value
      end
    end
  end
end

def eol = windows? ? "\r\n" : "\n"

# RSpec shared example for testing that a subject will call the git command line
# with the expected command and options.
#
# Must define the following context:
#   * subject - the subject of the test
#   * subject_object - the object that will receive the run_with_context method that will be mocked
#   * result - the result of the command
#
# Assumes that the subject will call #run_with_context with the command and options.
#
# @example
#   let(:subject) { worktree.add('file1.txt', 'file2.txt') }
#   let(:subject_object) { worktree }
#   let(:result) { instance_double(RubyGit::CommandLine::Result, stdout: '') }
#   it_behaves_line 'it runs the git command', [%w[add -- file1.txt]]
#
RSpec.shared_examples 'it runs the git command' do |command, options = Hash|
  it 'should build the correct command' do
    allow_any_instance_of(described_class).to(
      receive(:normalize_path) { |_, path| path }
    )

    if options.is_a?(Hash)
      # If specific options are given, double splat them into the argument list
      # binding.irb
      expect(subject_object).to(
        receive(:run_with_context).with(*command, **options)
      ).and_return(result)
    else
      # Otherwise assume options is a RSpec construct
      # binding.irb
      expect(subject_object).to(
        receive(:run_with_context).with(*command, options)
      ).and_return(result)
    end

    subject
  end
end

RSpec.shared_examples 'it raises a RubyGit::ArgumentError' do |message|
  it 'should raise an RubyGit::ArgumentError' do
    allow_any_instance_of(described_class).to(
      receive(:normalize_path) { |_, path| path }
    )

    expect { subject }.to(raise_error(RubyGit::ArgumentError, message))
  end
end

SimpleCov::RSpec.start(list_uncovered_lines: ci_build?)

require 'ruby_git'
