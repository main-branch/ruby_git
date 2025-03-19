# frozen_string_literal: true

module RubyGit
  # Sets and tracks the path to a git executable and reports the version
  #
  # @api public
  #
  class GitBinary
    # Return a new GitBinary object
    #
    # If the path is a command name, the command is search for in the PATH.
    #
    # If the path is a relative path, it is expanded to an absolute path relative to
    # the current directory.
    #
    # If the path is an absolute path, it is used as is.
    #
    # @example
    #   GitBinary.new
    #
    # @param [String] path the path to the git binary
    #
    def initialize(path = 'git')
      @path = Pathname.new(path) unless path.nil?
    end

    # @attribute [r] path
    #
    # The path to the git binary
    #
    # @example
    #   error.result #=> #<Pathname:git>
    #
    # @return [RubyGit::CommandLineResult]
    #
    attr_reader :path

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
      @path = Pathname.new(path)
    end

    # The version of git referred to by the path
    #
    # @example for version 2.28.0
    #   git = RubyGit::GitBinary.new
    #   git.version
    #    => [2, 28, 0]
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
