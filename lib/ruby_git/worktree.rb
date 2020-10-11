# frozen_string_literal: true

require 'open3'

module RubyGit
  # The Worktree is a directory tree consisting of the checked out files that
  # you are currently working on.
  #
  # Create a new Worktree using {.init}, {.clone}, or {.open}.
  #
  class Worktree
    # The root path of the worktree
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
      raise RubyGit::Error, "Path '#{worktree_path}' not valid." unless File.directory?(worktree_path)

      command = [RubyGit.git.path.to_s, 'init']
      _out, err, status = Open3.capture3(*command, chdir: worktree_path)
      raise RubyGit::Error, err unless status.success?

      Worktree.new(worktree_path)
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
      new(worktree_path)
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
      command = [RubyGit.git.path.to_s, 'clone', '--', repository_url, to_path]
      _out, err, status = Open3.capture3(*command)
      raise RubyGit::Error, err unless status.success?

      new(to_path)
    end

    private

    # Create a Worktree object
    # @api private
    def initialize(worktree_path)
      raise RubyGit::Error, "Path '#{worktree_path}' not valid." unless File.directory?(worktree_path)

      @path = root_path(worktree_path)
    end

    # Find the root path of a worktree containing `path`
    #
    # @raise [RubyGit::Error] if the path is not in a worktree
    #
    # @return [String] the root path of the worktree containing `path`
    #
    # @api private
    #
    def root_path(worktree_path)
      command = [RubyGit.git.path.to_s, 'rev-parse', '--show-toplevel']
      out, err, status = Open3.capture3(*command, chdir: worktree_path)
      raise RubyGit::Error, err unless status.success?

      out.chomp
    end
  end
end
