# frozen_string_literal: true

module RubyGit
  # Sets and tracks the path to a git executable and reports the version
  #
  # @api public
  #
  class GitBinary
    # Return a new GitBinary object
    #
    # @example
    #   GitBinary.new
    #
    def initialize(path = nil)
      @path = Pathname.new(path) unless path.nil?
    end

    # Sets the path to the git binary
    #
    # The given path must point to an executable file or a RuntimeError is raised.
    #
    # @example Setting the path to the git binary
    #   git.path = '/usr/local/bin/git'
    #
    # @param [String] path the path to a git executable
    #
    # @return [Pathname]
    #
    # @raise [RuntimeError] A RuntimeError is raised when the path does not refer
    #   to an existing executable file.
    #
    def path=(path)
      new_path = Pathname.new(path)
      raise "'#{new_path}' does not exist." unless new_path.exist?
      raise "'#{new_path}' is not a file." unless new_path.file?
      raise "'#{new_path}' is not executable." unless new_path.executable?

      @path = new_path
    end

    # Retrieve the path to the git binary
    #
    # @example Get the git found on the PATH
    #   git = RubyGit::GitBinary.new
    #   path = git.path
    #
    # @return [Pathname] the path to the git binary
    #
    # @raise [RuntimeError] if path was not set via `path=` and either PATH is not set
    #   or git was not found on the path.
    #
    def path
      @path || (@path = self.class.default_path)
    end

    # Get the default path to to a git binary by searching the PATH
    #
    # @example Find the pathname to `super_git`
    #   git = RubyGit::GitBinary.new
    #   git.path = git.default_path(basename: 'super_git')
    #
    # @param [String] basename The basename of the git command
    #
    # @return [Pathname] the path to the git binary found in the path
    #
    # @raise [RuntimeError] if either PATH is not set or an executable file
    #   `basename` was not found on the path.
    #
    def self.default_path(basename: 'git')
      RubyGit::FileHelpers.which(basename) || raise("Could not find '#{basename}' in the PATH.")
    end

    # The version of git referred to by the path
    #
    # @example for version 2.28.0
    #   git = RubyGit::GitBinary.new
    #   puts git.version #=> [2,28,0]
    #
    # @return [Array<Integer>] an array of integers representing the version.
    #
    # @raise [RuntimeError] if path was not set via `path=` and either PATH is not set
    #   or git was not found on the path.
    #
    def version
      output = `#{path} --version`
      version = output[/\d+\.\d+(\.\d+)+/]
      version.split('.').collect(&:to_i)
    end

    # Return the path as a string
    #
    # @example
    #   git = RubyGit::GitBinary.new('/usr/bin/git')
    #   git.to_s
    #    => '/usr/bin/git'
    #
    # @return [String] the path to the binary
    #
    # @raise [RuntimeError] if path was not set via `path=` and either PATH is not set
    #   or git was not found on the path.
    #
    def to_s
      path.to_s
    end
  end
end
