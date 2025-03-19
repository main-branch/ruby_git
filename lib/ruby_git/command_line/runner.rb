# frozen_string_literal: true

require_relative 'result'
require 'ruby_git/errors'

module RubyGit
  # Runs a git command and returns the result
  #
  # @api public
  #
  module CommandLine
    # Runs the git command line and returns the result
    # @api public
    class Runner
      # Create a an object to run git commands via the command line
      #
      # @example
      #   env = { 'GIT_DIR' => '/path/to/git/dir' }
      #   binary_path = '/usr/bin/git'
      #   global_options = %w[--git-dir /path/to/git/dir]
      #   logger = Logger.new(STDOUT)
      #   cli = CommandLine.new(env, binary_path, global_options, logger)
      #   cli.run('version') #=> #<RubyGit::CommandLineResult:0x00007f9b0c0b0e00
      #
      # @param env [Hash<String, String>] environment variables to set
      # @param global_options [Array<String>] global options to pass to git
      # @param logger [Logger] the logger to use
      #
      def initialize(env, binary_path, global_options, logger)
        @env = env
        @binary_path = binary_path
        @global_options = global_options
        @logger = logger
      end

      # @attribute [r] env
      #
      # Variables to set (or unset) in the git command's environment
      #
      # @example
      #   env = { 'GIT_DIR' => '/path/to/git/dir' }
      #   command_line = RubyGit::CommandLine.new(env, '/usr/bin/git', [], Logger.new(STDOUT))
      #   command_line.env #=> { 'GIT_DIR' => '/path/to/git/dir' }
      #
      # @return [Hash<String, String>]
      #
      # @see https://ruby-doc.org/3.2.1/Process.html#method-c-spawn Process.spawn
      #   for details on how to set environment variables using the `env` parameter
      #
      attr_reader :env

      # @attribute [r] binary_path
      #
      # The path to the command line binary to run
      #
      # @example
      #   binary_path = '/usr/bin/git'
      #   command_line = RubyGit::CommandLine.new({}, binary_path, ['version'], Logger.new(STDOUT))
      #   command_line.binary_path #=> '/usr/bin/git'
      #
      # @return [String]
      #
      attr_reader :binary_path

      # @attribute [r] global_options
      #
      # The global options to pass to git
      #
      # These are options that are passed to git before the command name and
      # arguments. For example, in `git --git-dir /path/to/git/dir version`, the
      # global options are %w[--git-dir /path/to/git/dir].
      #
      # @example
      #   env = {}
      #   global_options = %w[--git-dir /path/to/git/dir]
      #   logger = Logger.new(nil)
      #   cli = CommandLine.new(env, '/usr/bin/git', global_options, logger)
      #   cli.global_options #=> %w[--git-dir /path/to/git/dir]
      #
      # @return [Array<String>]
      #
      attr_reader :global_options

      # @attribute [r] logger
      #
      # The logger to use for logging git commands and results
      #
      # @example
      #   env = {}
      #   global_options = %w[]
      #   logger = Logger.new(STDOUT)
      #   cli = CommandLine.new(env, '/usr/bin/git', global_options, logger)
      #   cli.logger == logger #=> true
      #
      # @return [Logger]
      #
      attr_reader :logger

      # Execute a git command, wait for it to finish, and return the result
      #
      # NORMALIZATION
      #
      # The command output is returned as a Unicde string containing the binary output
      # from the command. If the binary output is not valid UTF-8, the output will
      # cause problems because the encoding will be invalid.
      #
      # Normalization is a process that trys to convert the binary output to a valid
      # UTF-8 string. It uses the `rchardet` gem to detect the encoding of the binary
      # output and then converts it to UTF-8.
      #
      # Normalization is not enabled by default. Pass `normalize: true` to RubyGit::CommandLine#run
      # to enable it. Normalization will only be performed on stdout and only if the `out:`` option
      # is nil or is a StringIO object. If the out: option is set to a file or other IO object,
      # the normalize option will be ignored.
      #
      # @example Run a command and return the output
      #   cli.run('version') #=> "git version 2.39.1\n"
      #
      # @example The args array should be splatted into the parameter list
      #   args = %w[log -n 1 --oneline]
      #   cli.run(*args) #=> "f5baa11 beginning of Ruby/Git project\n"
      #
      # @example Run a command and return the chomped output
      #   cli.run('version', chomp: true) #=> "git version 2.39.1"
      #
      # @example Run a command and without normalizing the output
      #   cli.run('version', normalize: false) #=> "git version 2.39.1\n"
      #
      # @example Capture stdout in a temporary file
      #   require 'tempfile'
      #   tempfile = Tempfile.create('git') do |file|
      #     cli.run('version', out: file)
      #     file.rewind
      #     file.read #=> "git version 2.39.1\n"
      #   end
      #
      # @example Capture stderr in a StringIO object
      #   require 'stringio'
      #   stderr = StringIO.new
      #   begin
      #     cli.run('log', 'nonexistent-branch', err: stderr)
      #   rescue RubyGit::FailedError => e
      #     stderr.string #=> "unknown revision or path not in the working tree.\n"
      #   end
      #
      # @param args [Array<String>] the command line arguements to pass to git
      #
      #   This array should be splatted into the parameter list.
      #
      # @param options_hash [Hash] the options to initialize {RubyGit::CommandLine::Options}
      #
      # @return [RubyGit::CommandLine::Result] the result of the command
      #
      # @raise [ArgumentError] if `args` or `options_hash` are not valid
      #
      # @raise [RubyGit::FailedError] if the command returned a non-zero exitstatus
      #
      # @raise [RubyGit::SignaledError] if the command was terminated because of an uncaught signal
      #
      # @raise [RubyGit::TimeoutError] if the command timeed out
      #
      # @raise [RubyGit::ProcessIOError] if an exception was raised while collecting subprocess output
      #
      def call(*args, **options_hash)
        options_hash[:raise_errors] = false
        options = RubyGit::CommandLine::Options.new(logger: logger, **options_hash)
        begin
          result = ProcessExecuter.run_with_options([env, *build_git_cmd(args)], options)
        rescue ProcessExecuter::ProcessIOError => e
          raise RubyGit::ProcessIOError.new(e.message), cause: e.exception.cause
        end
        process_result(result)
      end

      private

      # Build the git command line from the available sources to send to `Process.spawn`
      # @return [Array<String>]
      # @api private
      #
      def build_git_cmd(args)
        raise ArgumentError, 'The args array can not contain an array' if args.any? { |a| a.is_a?(Array) }

        [binary_path, *global_options, *args].map(&:to_s)
      end

      # Process the result of the command and return a RubyGit::CommandLineResult
      #
      # Post process output, log the command and result, and raise an error if the
      # command failed.
      #
      # @param result [ProcessExecuter::Result] the result it is a Process::Status
      #   and include command, stdout, and stderr
      #
      # @return [RubyGit::CommandLineResult] the result of the command to return to the caller
      #
      # @raise [RubyGit::FailedError] if the command failed
      # @raise [RubyGit::SignaledError] if the command was signaled
      # @raise [RubyGit::TimeoutError] if the command times out
      # @raise [RubyGit::ProcessIOError] if an exception was raised while collecting subprocess output
      #
      # @api private
      #
      def process_result(result)
        RubyGit::CommandLine::Result.new(result).tap do |processed_result|
          raise_any_errors(processed_result) if processed_result.options.raise_git_errors

          processed_result.process_stdout { |s, r| process_output(s, r) }
          processed_result.process_stderr { |s, r| process_output(s, r) }
        end
      end

      # Raise an error if the command failed, was signaled, or timed out
      #
      # @param result [RubyGit::CommandLineResult] the result of the command
      #
      # @return [Void]
      #
      # @raise [RubyGit::FailedError] if the command failed
      # @raise [RubyGit::SignaledError] if the command was signaled
      # @raise [RubyGit::TimeoutError] if the command times out
      #
      # @api private
      #
      def raise_any_errors(result)
        raise RubyGit::TimeoutError, result if result.timed_out?

        raise RubyGit::SignaledError, result if result.signaled?

        raise RubyGit::FailedError, result unless result.success?
      end

      # Determine the output to return in the `CommandLineResult`
      #
      # If the writer can return the output by calling `#string` (such as a StringIO),
      # then return the result of normalizing the encoding and chomping the output
      # as requested.
      #
      # If the writer does not support `#string`, then return nil. The output is
      # assumed to be collected by the writer itself such as when the  writer
      # is a file instead of a StringIO.
      #
      # @param output [#string] the output to post-process
      # @return [String, nil]
      #
      # @api private
      #
      def process_output(output, result)
        return nil unless output

        output =
          if result.options.normalize_encoding
            output.lines.map { |l| RubyGit::EncodingNormalizer.normalize(l) }.join
          else
            output.dup
          end

        output.tap { |o| o.chomp! if result.options.chomp }
      end
    end
  end
end
