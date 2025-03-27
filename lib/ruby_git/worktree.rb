# frozen_string_literal: true

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
    def self.clone(repository_url, to_path: nil)
      command = ['clone', '--', repository_url]
      command << to_path if to_path
      options = { out: StringIO.new, err: StringIO.new }
      clone_output = RubyGit::CommandLine.run(*command, **options).stderr
      new(cloned_to(clone_output))
    end

    # Get path of the cloned worktree from `git clone` stderr output
    #
    # @param clone_output [String] the stderr output of the `git clone` command
    #
    # @return [String] the path of the cloned worktree
    #
    # @api private
    def self.cloned_to(clone_output)
      clone_output.match(/Cloning into ['"](.+)['"]\.\.\./)[1]
    end

    # Show the working tree and index status
    #
    # @example worktree = Worktree.open(worktree_path) worktree.status #=>
    #   #<RubyGit::Status::Report ...>
    #
    # @param path_specs [Array<String>] paths to limit the status to
    #   (default is all paths)
    #
    #   See [git-glossary
    #   pathspec](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefpathspecapathspec).
    #
    # @param untracked_files [:all, :normal, :no] Defines how untracked files will be
    # handled
    #
    #   See [git-staus
    #   --untracked-files](https://git-scm.com/docs/git-status#Documentation/git-status.txt---untracked-filesltmodegt).
    #
    # @param ignored [:traditional, :matching, :no] Defines how ignored files will be
    # handled, :no to not include ignored files
    #
    #   See [git-staus
    #   --ignored](https://git-scm.com/docs/git-status#Documentation/git-status.txt---ignoredltmodegt).
    #
    # @param ignore_submodules [:all, :dirty, :untracked, :none] Default is :all
    #
    #   See [git-staus
    #   --ignore-submodules](https://git-scm.com/docs/git-status#Documentation/git-status.txt---ignore-submodulesltwhengt).
    #
    # @return [RubyGit::Status::Report] the status of the working tree
    #
    def status(*path_specs, untracked_files: :all, ignored: :no, ignore_submodules: :all) # rubocop:disable Metrics/MethodLength
      command = %w[status --porcelain=v2 --branch --show-stash --ahead-behind --renames -z]
      command << "--untracked-files=#{untracked_files}"
      command << "--ignored=#{ignored}"
      command << "--ignore-submodules=#{ignore_submodules}"
      unless path_specs.empty?
        command << '--'
        command.concat(path_specs)
      end
      options = { out: StringIO.new, err: StringIO.new }
      status_output = run(*command, **options).stdout
      RubyGit::Status.parse(status_output)
    end

    # Return the repository associated with the worktree
    #
    # @example
    #   worktree = Worktree.open(worktree_path)
    #   worktree.repository #=> #<RubyGit::Repository ...>
    #
    # @return [RubyGit::Repository] the repository associated with the worktree
    #
    def repository
      @repository ||= begin
        command = %w[rev-parse --git-dir]
        options = { chdir: path, chomp: true, out: StringIO.new, err: StringIO.new }
        # rev-parse path might be relative to the worktree, thus the need to expand it
        git_dir = File.realpath(RubyGit::CommandLine.run(*command, **options).stdout, path)
        Repository.new(git_dir)
      end
    end

    private

    # Create a Worktree object
    #
    # @param worktree_path [String] a path anywhere in the worktree
    #
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
      File.realpath(RubyGit::CommandLine.run(*command, **options).stdout)
    end

    # Run a Git command in this worktree
    #
    # Passes the repository path and worktree path to RubyGit::CommandLine.run
    #
    # @param command [Array<String>] the git command to run
    # @param options [Hash] options to pass to RubyGit::CommandLine.run
    #
    # @return [RubyGit::CommandLineResult] the result of the git command
    #
    # @api private
    #
    def run(*command, **options)
      RubyGit::CommandLine.run(*command, repository_path: repository.path, worktree_path: path, **options)
    end
  end
end
