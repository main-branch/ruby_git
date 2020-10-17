# frozen_string_literal: true

require 'open3'

module RubyGit
  # The working tree is a directory tree consisting of the checked out files that
  # you are currently working on.
  #
  # Create a new WorkingTree using {.init}, {.clone}, or {.open}.
  #
  class WorkingTree
    # The root path of the working tree
    #
    # @example
    #   working_tree_path = '/Users/James/myproject'
    #   working_tree = WorkingTree.open(working_tree_path)
    #   working_tree.path
    #    => '/Users/James/myproject'
    #
    # @return [Pathname] the root path of the working_tree
    #
    attr_reader :path

    # Create an empty Git repository under the root working tree `path`
    #
    # If the repository already exists, it will not be overwritten.
    #
    # @see https://git-scm.com/docs/git-init git-init
    #
    # @example
    #   working_tree = WorkingTree.init(working_tree_path)
    #
    # @param [String] working_tree_path the root path of a Git working tree
    #
    # @raise [RubyGit::Error] if working_tree_path is not a directory
    #
    # @return [RubyGit::WorkingTree] the working tree whose root is at `path`
    #
    def self.init(working_tree_path)
      raise RubyGit::Error, "Path '#{working_tree_path}' not valid." unless File.directory?(working_tree_path)

      command = [RubyGit.git.path.to_s, 'init']
      _out, err, status = Open3.capture3(*command, chdir: working_tree_path)
      raise RubyGit::Error, err unless status.success?

      WorkingTree.new(working_tree_path)
    end

    # Open an existing Git working tree that contains working_tree_path
    #
    # @see https://git-scm.com/docs/git-open git-open
    #
    # @example
    #   working_tree = WorkingTree.open(working_tree_path)
    #
    # @param [String] working_tree_path the root path of a Git working tree
    #
    # @raise [RubyGit::Error] if `working_tree_path` does not exist, is not a directory, or is not within
    #   a Git working tree.
    #
    # @return [RubyGit::WorkingTree] the Git working tree that contains `working_tree_path`
    #
    def self.open(working_tree_path)
      new(working_tree_path)
    end

    # Copy the remote repository and checkout the default branch
    #
    # Clones the repository referred to by `repository_url` into a newly created
    # directory, creates remote-tracking branches for each branch in the cloned repository,
    # and checks out the default branch in the Git working tree whose root directory is `to_path`.
    #
    # @see https://git-scm.com/docs/git-clone git-clone
    #
    # @example Using default for WorkingTree path
    #   FileUtils.pwd
    #    => "/Users/jsmith"
    #   working_tree = WorkingTree.clone('https://github.com/main-branch/ruby_git.git')
    #   working_tree.path
    #    => "/Users/jsmith/ruby_git"
    #
    # @example Using a specified working_tree_path
    #   FileUtils.pwd
    #    => "/Users/jsmith"
    #   working_tree_path = '/tmp/project'
    #   working_tree = WorkingTree.clone('https://github.com/main-branch/ruby_git.git', to_path: working_tree_path)
    #   working_tree.path
    #    => "/tmp/project"
    #
    # @param [String] repository_url a reference to a Git repository
    #
    # @param [String] to_path where to put the checked out Git working tree once the repository is cloned
    #
    # `to_path` will be created if it does not exist.  An error is raised if `to_path` exists and
    # not an empty directory.
    #
    # @raise [RubyGit::Error] if (1) `repository_url` is not valid or does not point to a valid repository OR
    #   (2) `to_path` is not an empty directory.
    #
    # @return [RubyGit::WorkingTree] the Git working tree checked out from the cloned repository
    #
    def self.clone(repository_url, to_path: '')
      command = [RubyGit.git.path.to_s, 'clone', '--', repository_url, to_path]
      _out, err, status = Open3.capture3(*command)
      raise RubyGit::Error, err unless status.success?

      new(to_path)
    end

    private

    # Create a WorkingTree object
    # @api private
    #
    def initialize(working_tree_path)
      raise RubyGit::Error, "Path '#{working_tree_path}' not valid." unless File.directory?(working_tree_path)

      @path = root_path(working_tree_path)
      RubyGit.logger.debug("Created #{inspect}")
    end

    # Find the root path of a Git working tree containing `path`
    #
    # @raise [RubyGit::Error] if the path is not in a Git working tree
    #
    # @return [String] the root path of the Git working tree containing `path`
    #
    # @api private
    #
    def root_path(working_tree_path)
      command = [RubyGit.git.path.to_s, 'rev-parse', '--show-toplevel']
      out, err, status = Open3.capture3(*command, chdir: working_tree_path)
      raise RubyGit::Error, err unless status.success?

      out.chomp
    end
  end
end
