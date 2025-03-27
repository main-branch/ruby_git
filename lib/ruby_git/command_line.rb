# frozen_string_literal: true

require_relative 'command_line/options'
require_relative 'command_line/result'
require_relative 'command_line/runner'

module RubyGit
  # Run git commands via the command line
  #
  # @api public
  #
  module CommandLine
    # Run a git command
    #
    # @example A simple example
    #   RubyGit::CommandLine.run('version') #=> outputs "git version 2.30.2\n" to stdout
    #
    # @example Capture stdout
    #   command = %w[version]
    #   options = { out: StringIO.new }
    #   result = RubyGit::CommandLine.run(*command, **options) #=> #<Process::Status: pid 21742 exit 0>
    #   result.stdout #=> "git version 2.30.2\n"
    #
    # @example A more complex example
    #   command = %w[rev-parse --show-toplevel]
    #   options = { git_chdir: worktree_path, chomp: true, out: StringIO.new, err: StringIO.new }
    #   RubyGit::CommandLine.run(*command, **options).stdout #=> "/path/to/working/tree"
    #
    # @param args [Array<String>] the git command and it arguments
    # @param repository_path [String, nil] the path to the git repository
    # @param worktree_path [String, nil] the path to the working tree
    # @param git_chdir [String, nil] the path to change to before running the command
    # @param options [Hash<Symbol, Object>] options to pass to the command line runner
    #
    # @return [RubyGit::CommandLine::Result] the result of running the command
    #
    # @raise [RubyGit::Error] if the command fails for any of the following reasons
    # @raise [RubyGit::FailedError] if the command returns with non-zero exitstatus
    # @raise [RubyGit::TimeoutError] if the command times out
    # @raise [RubyGit::SignaledError] if the command terminates due to an uncaught signal
    # @raise [RubyGit::ProcessIOError] if an exception is raised while collecting subprocess output
    #
    def self.run(*args, repository_path: nil, worktree_path: nil, git_chdir: nil, **options)
      runner = RubyGit::CommandLine::Runner.new(
        env,
        binary_path,
        global_options(repository_path:, worktree_path:, git_chdir:),
        logger
      )
      runner.call(*args, **options)
    end

    # The environment variables that will be set for all git commands
    # @return [Hash<String, String>]
    # @api private
    def self.env
      {
        'GIT_DIR' => nil,
        'GIT_WORK_TREE' => nil,
        'GIT_INDEX_FILE' => nil,
        # 'GIT_SSH' => Git::Base.config.git_ssh,
        'LC_ALL' => 'en_US.UTF-8'
      }
    end

    # The path to the git binary
    # @return [String]
    # @api private
    def self.binary_path = RubyGit.binary_path

    # The global options that will be set for all git commands
    # @return [Array<String>]
    # @api private
    def self.global_options(repository_path:, worktree_path:, git_chdir:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      [].tap do |global_opts|
        global_opts << "--git-dir=#{repository_path}" unless repository_path.nil?
        global_opts << "--work-tree=#{worktree_path}" unless worktree_path.nil?
        global_opts << '-C' << git_chdir unless git_chdir.nil?
        global_opts << '-c' << 'core.quotePath=true'
        global_opts << '-c' << 'color.ui=false'
        global_opts << '-c' << 'color.advice=false'
        global_opts << '-c' << 'color.diff=false'
        global_opts << '-c' << 'color.grep=false'
        global_opts << '-c' << 'color.push=false'
        global_opts << '-c' << 'color.remote=false'
        global_opts << '-c' << 'color.showBranch=false'
        global_opts << '-c' << 'color.status=false'
        global_opts << '-c' << 'color.transport=false'
      end
    end

    # The logger to use for logging git commands
    # @return [Logger]
    # @api private
    def self.logger = RubyGit.logger
  end
end
