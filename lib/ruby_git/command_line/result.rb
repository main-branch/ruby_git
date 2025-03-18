# frozen_string_literal: true

require 'delegate'
require 'process_executer'

module RubyGit
  module CommandLine
    # The result of running a git command
    #
    # Adds stdout and stderr processing to the `ProcessExecuter::Result` class.
    #
    # @api public
    #
    class Result < SimpleDelegator
      # @!method initialize(result)
      #   Initialize a new result object
      #   @example
      #     result = ProcessExecuter.run('echo hello')
      #     RubyGit::CommandLine::Result.new(result)
      #   @param [ProcessExecuter::Result] result The result of running the command
      #   @return [RubyGit::CommandLine::Result]
      #   @api public

      # Return the processed stdout output (or original if it was not processed)
      #
      # This output is only returned if a stdout redirection is a
      # `ProcessExecuter::MonitoredPipe`.
      #
      # @example
      #   result = ProcessExecuter.run('echo hello': out: StringIO.new)
      #   result.stdout #=> "hello\n"
      #
      # @return [String, nil]
      #
      def stdout
        defined?(@processed_stdout) ? @processed_stdout : unprocessed_stdout
      end

      # Process the captured stdout output
      #
      # @example
      #   result = ProcessExecuter.run('echo hello', out: StringIO.new)
      #   result.stdout #=> "hello\n"
      #   result.process_stdout { |stdout, _result| stdout.upcase }
      #   result.stdout #=> "HELLO\n"
      #   result.unprocessed_stdout #=> "hello\n"
      #
      # @example Chain processing
      #   result = ProcessExecuter.run('echo hello', out: StringIO.new)
      #   result.stdout #=> "hello\n"
      #   result.process_stdout { |s| s.upcase }.process_stdout { |s| s.reverse }
      #   result.stdout #=> "OLLEH\n"
      #   result.unprocessed_stdout #=> "hello\n"
      #
      # @return [String, nil]
      #
      # @yield [stdout, result] Yields the stdout output and the result object
      # @yieldparam stdout [String] The output to process
      # @yieldparam result [RubyGit::CommandLine::Result] This object (aka self)
      # @yieldreturn [String] The processed stdout output
      #
      # @api public
      #
      def process_stdout(&block)
        return if block.nil?

        @processed_stdout = block.call(stdout, self)
        self
      end

      # Returns the original stdout output before it was processed
      #
      # @example
      #   result = ProcessExecuter.run('echo hello', out: StringIO.new)
      #   result.stdout #=> "hello\n"
      #   result.unprocessed_stdout #=> "hello\n"
      #   result.process_stdout { |s| s.upcase }
      #   result.stdout #=> "HELLO\n"
      #   result.unprocessed_stdout #=> "hello\n"
      #
      # @return [String, nil]
      #
      # @api public
      #
      def unprocessed_stdout
        __getobj__.stdout
      end

      # Return the processed stderr output (or original if it was not processed)
      #
      # This output is only returned if a stderr redirection is a
      # `ProcessExecuter::MonitoredPipe`.
      #
      # @example
      #   result = ProcessExecuter.run('echo hello 1>&2': err: StringIO.new)
      #   result.stderr #=> "hello\n"
      #
      # @return [String, nil]
      #
      def stderr
        defined?(@processed_stderr) ? @processed_stderr : unprocessed_stderr
      end

      # Process the captured stderr output
      #
      # @example
      #   result = ProcessExecuter.run('echo hello 1>&2', err: StringIO.new)
      #   result.stderr #=> "hello\n"
      #   result.process_stderr { |stderr, _result| stderr.upcase }
      #   result.stderr #=> "HELLO\n"
      #   result.unprocessed_stderr #=> "hello\n"
      #
      # @example Chain processing
      #   result = ProcessExecuter.run('echo hello 1>&2', err: StringIO.new)
      #   result.stderr #=> "hello\n"
      #   result.process_stderr { |s| s.upcase }.process_stderr { |s| s.reverse }
      #   result.stderr #=> "OLLEH\n"
      #   result.unprocessed_stderr #=> "hello\n"
      #
      # @return [String, nil]
      #
      # @yield [stderr, result] Yields the stderr output and the result object
      # @yieldparam stderr [String] The output to process
      # @yieldparam result [RubyGit::CommandLine::Result] This object (aka self)
      # @yieldreturn [String] The processed stderr output
      #
      # @api public
      #
      def process_stderr(&block)
        return if block.nil?

        @processed_stderr = block.call(stderr, self)
        self
      end

      # Returns the original stderr output before it was processed
      #
      # @example
      #   result = ProcessExecuter.run('echo hello 1>&2', err: StringIO.new)
      #   result.stderr #=> "hello\n"
      #   result.unprocessed_stderr #=> "hello\n"
      #   result.process_stderr { |stderr| stderr.upcase }
      #   result.stderr #=> "HELLO\n"
      #   result.unprocessed_stderr #=> "hello\n"
      #
      # @return [String, nil]
      #
      # @api public
      #
      def unprocessed_stderr
        __getobj__.stderr
      end
    end
  end
end
