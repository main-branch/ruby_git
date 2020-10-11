# frozen_string_literal: true

require 'ruby_git/error'
require 'ruby_git/file_helpers'
require 'ruby_git/git_binary'
require 'ruby_git/version'
require 'ruby_git/worktree'

# RubyGit is an object-oriented wrapper for the `git` command line tool for
# working with Worktrees and Repositories. It tries to make more sense out
# of the Git command line.
#
# @api public
#
module RubyGit
  # Return information about the git binary used by this library
  #
  # Use this object to set the path to the git binary to use or to see the
  # path being used.
  #
  # @example Setting the git binary path
  #    RubyGit.git.path = '/usr/local/bin/git'
  #
  # @return [RubyGit::GitBinary]
  #
  def self.git
    (@git ||= RubyGit::GitBinary.new)
  end

  # Create an empty Git repository under the root worktree `path`
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

  # Open an existing Git worktree that contains worktree_path
  #
  # @see https://git-scm.com/docs/git-open git-open
  #
  # @example
  #   worktree = Worktree.open(worktree_path)
  #
  # @param [String] worktree_path the root path of a worktree
  #
  # @raise [RubyGit::Error] if `worktree_path` does not exist, is not a directory, or is not within a Git worktree.
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
  #     => "/Users/jsmith/ruby_git"
  #
  # @example Using a specified worktree_path
  #   FileUtils.pwd
  #    => "/Users/jsmith"
  #   worktree_path = '/tmp/project'
  #   worktree = Worktree.clone('https://github.com/main-branch/ruby_git.git', to_path: worktree_path)
  #   worktree.path
  #     => "/tmp/project"
  #
  # @param [String] repository_url a reference to a Git repository
  #
  # @param [String] to_path where to put the checked out worktree once the repository is cloned
  #
  # `to_path` will be created if it does not exist.  An error is raised if `to_path` exists and
  # not an empty directory.
  #
  # @raise [RubyGit::Error] if (1) `repository_url` is not valid or does not point to a valid repository OR
  #   (2) `to_path` is not an empty directory.
  #
  # @return [RubyGit::Worktree] the worktree checked out from the cloned repository
  #
  def self.clone(repository_url, to_path: '')
    RubyGit::Worktree.clone(repository_url, to_path: to_path)
  end
end
