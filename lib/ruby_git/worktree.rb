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
    def self.init(worktree_path, normalize_path: true)
      raise RubyGit::Error, "Path '#{worktree_path}' not valid." unless File.directory?(worktree_path)

      command = ['init']
      options = { chdir: worktree_path, out: StringIO.new, err: StringIO.new }
      RubyGit::CommandLine.run(*command, **options)

      new(worktree_path, normalize_path:)
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
    def self.open(worktree_path, normalize_path: true)
      new(worktree_path, normalize_path:)
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
    def self.clone(repository_url, to_path: nil, normalize_path: true)
      command = ['clone', '--', repository_url]
      command << to_path if to_path
      options = { out: StringIO.new, err: StringIO.new }
      clone_output = RubyGit::CommandLine.run(*command, **options).stderr
      new(cloned_to(clone_output), normalize_path:)
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
    def status(*path_specs, untracked_files: :all, ignored: :no, ignore_submodules: :all)
      command = %w[status --porcelain=v2 --branch --show-stash --ahead-behind --renames -z]
      command << "--untracked-files=#{untracked_files}"
      command << "--ignored=#{ignored}"
      command << "--ignore-submodules=#{ignore_submodules}"
      command << '--' unless path_specs.empty?
      command.concat(path_specs)
      options = { out: StringIO.new, err: StringIO.new }
      status_output = run_with_context(*command, **options).stdout
      RubyGit::Status.parse(status_output)
    end

    # Add changed files to the index to stage for the next commit
    #
    # @example
    #   worktree = Worktree.open(worktree_path)
    #   worktree.add('file1.txt', 'file2.txt')
    #   worktree.add('.')
    #   worktree.add(all: true)
    #
    # @param pathspecs [Array<String>] paths to add to the index
    # @param all [Boolean] adds, updates, and removes index entries to match the working tree (entire repo)
    # @param force [Boolean] add files even if they are ignored
    # @param refresh [Boolean] only refresh each files stat information in the index
    # @param update [Boolean] add all updated and deleted files to the index but does not add any files
    #
    # @see https://git-scm.com/docs/git-add git-add
    #
    # @return [RubyGit::CommandLineResult] the result of the git add command
    #
    # @raise [ArgumentError] if any of the options are not valid
    #
    def add(*pathspecs, all: false, force: false, refresh: false, update: false) # rubocop:disable Metrics/MethodLength
      validate_boolean_option(name: :all, value: all)
      validate_boolean_option(name: :force, value: force)
      validate_boolean_option(name: :refresh, value: refresh)
      validate_boolean_option(name: :update, value: update)

      command = %w[add]
      command << '--all' if all
      command << '--force' if force
      command << '--update' if update
      command << '--refresh' if refresh
      command << '--' unless pathspecs.empty?
      command.concat(pathspecs)

      options = { out: StringIO.new, err: StringIO.new }

      run_with_context(*command, **options)
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
        Repository.new(git_dir, normalize_path: normalize_path?)
      end
    end

    private

    # Create a Worktree object
    #
    # @param worktree_path [String] a path anywhere in the worktree
    # @param normalize_path [Boolean] if true, path is converted to an absolute path to the root of the working tree
    #
    #   The purpose of this flag is to allow tests to not have to mock the
    #   normalization of the path. This allows testing that the right git command
    #   is contructed based on the options passed any particular method.
    #
    # @raise [ArgumentError] if the path is not a directory or the path is not in a
    #   git working tree
    #
    # @return [RubyGit::Worktree] the worktree whose root is at `path`
    # @api private
    #
    def initialize(worktree_path, normalize_path: true)
      @normalize_path = normalize_path

      @path =
        if normalize_path?
          normalize_worktree_path(worktree_path)
        else
          worktree_path
        end

      RubyGit.logger.debug("Created #{inspect}")
    end

    # Get path of the cloned worktree from `git clone` stderr output
    #
    # @param clone_output [String] the stderr output of the `git clone` command
    #
    # @return [String] the path of the cloned worktree
    #
    # @api private
    private_class_method def self.cloned_to(clone_output)
      clone_output.match(/Cloning into ['"](.+)['"]\.\.\./)[1]
    end

    # True if the path should be normalized
    #
    # This means that the path should be expanded and converted to a absolute, real
    # path to the working tree root dir.
    #
    # @return [Boolean]
    #
    # @api private
    #
    def normalize_path? = @normalize_path

    # Return the absolute path to the root of the working tree containing path
    #
    # @example Expand the path
    #   normalize_path('~/worktree') #=> '/Users/james/worktree'
    #
    # @example Convert to an absolute path
    #   File.chdir('/User/james/worktree')
    #   normalize_path('.') #=> '/User/james/worktree'
    #
    # @param path [String] a (possibly relative) path within the worktree
    #
    # @return [String]
    #
    # @raise [ArgumentError] if the path is not a directory or the path is not in a
    #   git working tree
    #
    # @api private
    #
    def normalize_worktree_path(path)
      raise ArgumentError, "Directory '#{path}' does not exist." unless File.directory?(path)

      begin
        root_path(path)
      rescue RubyGit::FailedError => e
        raise ArgumentError, e.message
      end
    end

    # Find the root path of a Git working tree containing `path`
    #
    # @return [String] the root path of the Git working tree containing `path`
    #
    # @raise [ArgumentError] if the path is not in a Git working tree
    #
    # @api private
    #
    def root_path(worktree_path)
      command = %w[rev-parse --show-toplevel]
      options = { chdir: worktree_path, chomp: true, out: StringIO.new, err: StringIO.new }
      root_path = RubyGit::CommandLine.run(*command, **options).stdout
      File.realpath(File.expand_path(root_path))
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
    def run_with_context(*command, **options)
      RubyGit::CommandLine.run(*command, repository_path: repository.path, worktree_path: path, **options)
    end

    # Raise an error if an option is not a Boolean (or optionally nil) value
    # @param name [String] the name of the option
    # @param value [Object] the value of the option
    # @param nullable [Boolean] whether the option can be nil (default is false)
    # @return [void]
    # @raise [ArgumentError] if the option is not a Boolean (or optionally nil) value
    # @api private
    def validate_boolean_option(name:, value:, nullable: false)
      return if nullable && value.nil?

      return if [true, false].include?(value)

      raise ArgumentError, "The '#{name}:' option must be a Boolean value but was #{value.inspect}"
    end
  end
end
