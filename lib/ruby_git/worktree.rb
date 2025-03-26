# frozen_string_literal: true

require 'open3'

module RubyGit
  # The working tree is a directory tree consisting of the checked out files that
  # you are currently working on.
  #
  # Create a new Worktree using {.init}, {.clone}, or {.open}.
  #
  class Worktree
    # The root path of the working tree
    #
    # @example
    #   worktree_path = '/Users/James/myproject'
    #   worktree = Worktree.open(worktree_path)
    #   worktree.path
    #    => '/Users/James/myproject'
    #
    # @return [Pathname] the root path of the worktree
    #
    attr_reader :path

    # Create an empty Git repository under the root working tree `path`
    #
    # If the repository already exists, it will not be overwritten.
    #
    # @see https://git-scm.com/docs/git-init git-init
    #
    # @example
    #   worktree = Worktree.init(worktree_path)
    #
    # @param [String] worktree_path the root path of a Git working tree
    #
    # @raise [RubyGit::Error] if worktree_path is not a directory
    #
    # @return [RubyGit::Worktree] the working tree whose root is at `path`
    #
    def self.init(worktree_path)
      raise RubyGit::Error, "Path '#{worktree_path}' not valid." unless File.directory?(worktree_path)

      command = ['init']
      options = { chdir: worktree_path, out: StringIO.new, err: StringIO.new }
      RubyGit::CommandLine.run(*command, **options)

      new(worktree_path)
    end

    # Open an existing Git working tree that contains worktree_path
    #
    # @see https://git-scm.com/docs/git-open git-open
    #
    # @example
    #   worktree = Worktree.open(worktree_path)
    #
    # @param [String] worktree_path the root path of a Git working tree
    #
    # @raise [RubyGit::Error] if `worktree_path` does not exist, is not a directory, or is not within
    #   a Git working tree.
    #
    # @return [RubyGit::Worktree] the Git working tree that contains `worktree_path`
    #
    def self.open(worktree_path)
      new(worktree_path)
    end

    # Copy the remote repository and checkout the default branch
    #
    # Clones the repository referred to by `repository_url` into a newly created
    # directory, creates remote-tracking branches for each branch in the cloned repository,
    # and checks out the default branch in the Git working tree whose root directory is `to_path`.
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
    # @param [String] to_path where to put the checked out Git working tree once the repository is cloned
    #
    # `to_path` will be created if it does not exist.  An error is raised if `to_path` exists and
    # not an empty directory.
    #
    # @raise [RubyGit::FailedError] if (1) `repository_url` is not valid or does not point to a valid repository OR
    #   (2) `to_path` is not an empty directory.
    #
    # @return [RubyGit::Worktree] the Git working tree checked out from the cloned repository
    #
    def self.clone(repository_url, to_path: '')
      command = ['clone', '--', repository_url, to_path]
      options = { out: StringIO.new, err: StringIO.new }
      RubyGit::CommandLine.run(*command, **options)
      new(to_path)
    end

    private

    # Create a Worktree object
    # @api private
    #
    def initialize(worktree_path)
      raise RubyGit::Error, "Path '#{worktree_path}' not valid." unless File.directory?(worktree_path)

      @path = root_path(worktree_path)
      RubyGit.logger.debug("Created #{inspect}")
    end

    # Find the root path of a Git working tree containing `path`
    #
    # @raise [RubyGit::FailedError] if the path is not in a Git working tree
    #
    # @return [String] the root path of the Git working tree containing `path`
    #
    # @api private
    #
    def root_path(worktree_path)
      command = %w[rev-parse --show-toplevel]
      options = { chdir: worktree_path, chomp: true, out: StringIO.new, err: StringIO.new }
      RubyGit::CommandLine.run(*command, **options).stdout
    end

    # def run(*command, **options)
    #   RubyGit::CommandLine.run(*command, worktree_path: path, **options)
    # end

    # #
    # # @param untracked_files [Symbol] Can be :all, :normal, :no
    # # @param ignore_submodules [Symbol] Can be :all, :dirty, :untracked, :none
    # # @param ignored [Symbol] Can be :traditional, :matching, :no
    # # @param renames [Boolean] Whether to detect renames
    # def status(untracked_files:)
    #   # -z for null-terminated output
    #   # --porcelain for machine-readable output
    #   git status --porcelain=v2 --untracked-files --branch --show-stash --ahead-behind --renames -z
    #   command = ['status', '--porcelain', '--branch', '-z']
    #   command << '--untracked-files=all' if untracked_files == :all
    #   command << '--untracked-files=no' if untracked_files == :no
    #   options = { chdir: path, out: StringIO.new, err: StringIO.new }
    #   result = RubyGit::CommandLine.run(*command, **options)
    #   result.stdout
    # end
  end
end
