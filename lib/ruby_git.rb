# frozen_string_literal: true

require_relative 'ruby_git/command_line'
require_relative 'ruby_git/encoding_normalizer'
require_relative 'ruby_git/errors'
require_relative 'ruby_git/option_validators'
require_relative 'ruby_git/repository'
require_relative 'ruby_git/status'
require_relative 'ruby_git/version'
require_relative 'ruby_git/worktree'

require 'logger'

# The RubyGit module provides a Ruby API that is an object-oriented wrapper around
# the `git` command line. It is intended to make automating both simple and complex Git
# interactions easier. To accomplish this, it ties each action you can do with `git` to
# the type of object that action operates on.
#
# There are three main objects in RubyGit:
# * {Worktree}: The directory tree of actual checked
#   out files. The working tree normally contains the contents of the HEAD commit's
#   tree, plus any local changes that you have made but not yet committed.
# * Index: The index is used as a staging area between your
#   working tree and your repository. You can use the index to build up a set of changes
#   that you want to commit together. When you create a commit, what is committed is what is
#   currently in the index, not what is in your working directory.
# * Repository: The repository stores the files in a project,
#   their history, and other meta data like commit information, tags, and branches.
#
# @api public
#
module RubyGit
  @logger = Logger.new(nil)

  class << self
    # The logger used by the RubyGit gem (Logger.new(nil) by default)
    #
    # @example Using the logger
    #   RubyGit.logger.debug('Debug message')
    #
    # @example Setting the logger
    #   require 'logger'
    #   require 'stringio'
    #   log_device = StringIO.new
    #   RubyGit.logger = Logger.new(log_device, level: Logger::DEBUG)
    #   RubyGit.logger.debug('Debug message')
    #   log_device.string.include?('Debug message')
    #    => true
    #
    # @return [Logger] the logger used by the RubyGit gem
    #
    attr_accessor :logger
  end

  @binary_path = 'git'

  class << self
    # The path to the git binary used by the RubyGit gem
    #
    # * If the path is a command name, the command is search for in the PATH.
    #
    # * If the path is a relative path, it relative to the current directory (not
    #   recommended as this will change as the current directory is changed).
    #
    # * If the path is an absolute path, it is used as is.
    #
    # @example
    #   RubyGit.binary_path
    #    => "git"
    #
    # @return [String]
    #
    attr_accessor :binary_path
  end

  # Create an empty Git repository under the root working tree `path`
  #
  # If the repository already exists, it will not be overwritten.
  #
  # @see https://git-scm.com/docs/git-init git-init
  #
  # @example
  #   worktree = Worktree.init(worktree_path)
  #
  # @param [String] worktree_path the root path of a worktree
  #
  # @raise [RubyGit::Error] if worktree_path is not a directory
  #
  # @return [RubyGit::Worktree] the worktree whose root is at `path`
  #
  def self.init(worktree_path)
    RubyGit::Worktree.init(worktree_path)
  end

  # Open an existing Git working tree that contains worktree_path
  #
  # @see https://git-scm.com/docs/git-open git-open
  #
  # @example
  #   worktree = Worktree.open(worktree_path)
  #
  # @param [String] worktree_path the root path of a worktree
  #
  # @raise [RubyGit::Error] if `worktree_path` does not exist, is not a directory, or is not within
  #   a Git worktree.
  #
  # @return [RubyGit::Worktree] the worktree that contains `worktree_path`
  #
  def self.open(worktree_path)
    RubyGit::Worktree.open(worktree_path)
  end

  # Copy the remote repository and checkout the default branch
  #
  # Clones the repository referred to by `repository_url` into a newly created
  # directory, creates remote-tracking branches for each branch in the cloned repository,
  # and checks out the default branch in the worktree whose root directory is `to_path`.
  #
  # @see https://git-scm.com/docs/git-clone git-clone
  #
  # @example Using default for Worktree path
  #   FileUtils.pwd
  #    => "/Users/jsmith"
  #   worktree = Worktree.clone('https://github.com/main-branch/ruby_git.git')
  #   worktree.path
  #    => "/Users/jsmith/ruby_git"
  #
  # @example Using a specified worktree_path
  #   FileUtils.pwd
  #    => "/Users/jsmith"
  #   worktree_path = '/tmp/project'
  #   worktree = Worktree.clone('https://github.com/main-branch/ruby_git.git', to_path: worktree_path)
  #   worktree.path
  #    => "/tmp/project"
  #
  # @param [String] repository_url a reference to a Git repository
  #
  # @param [String] to_path where to put the checked out working tree once the repository is cloned
  #
  # `to_path` will be created if it does not exist.  An error is raised if `to_path` exists and
  # not an empty directory.
  #
  # @raise [RubyGit::Error] if (1) `repository_url` is not valid or does not point to a valid repository OR
  #   (2) `to_path` is not an empty directory.
  #
  # @return [RubyGit::Worktree] the working tree checked out from the cloned repository
  #
  def self.clone(repository_url, to_path: '')
    RubyGit::Worktree.clone(repository_url, to_path:)
  end

  # The version of git referred to by the path
  #
  # @example for version 2.28.0
  #   RubyGit.binary_version #=> [2, 28, 0]
  #
  # @return [Array<Integer>] an array of integers representing the version.
  #
  # @raise [RuntimeError] if path was not set via `path=` and either PATH is not set
  #   or git was not found on the path.
  #
  def self.binary_version
    command = %w[version]
    options = { out: StringIO.new, err: StringIO.new }
    version_string = RubyGit::CommandLine.run(*command, **options).stdout[/\d+\.\d+(\.\d+)+/]
    version_string.split('.').collect(&:to_i)
  end
end
