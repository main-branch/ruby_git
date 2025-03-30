# frozen_string_literal: true

module RubyGit
  # The repository is the database of all the objects, refs, and other data that
  # make up the history of a project.
  #
  # @api public
  #
  class Repository
    # @attribute [r] path
    #
    # The absolute path to the repository
    #
    # @example
    #  repository = RubyGit::Repository.new('.git')
    #  repository.path = '/absolute/path/.git'
    #
    # @return [String]
    #
    attr_reader :path

    # Create a new Repository object with the given repository path
    #
    # @example
    #   RubyGit::Repository.new('/path/to/repository') #=> #<RubyGit::Repository ...>
    #
    # @param [String] repository_path the path to the repository
    # @param normalize_path [Boolean] if true, path is converted to an absolute path to the root of the working tree
    #
    #   The purpose of this flag is to allow tests to not have to mock the
    #   normalization of the path. This allows testing that the right git command
    #   is contructed based on the options passed any particular method.
    #
    # @raise [ArgumentError] if the path is not a directory
    #
    def initialize(repository_path, normalize_path: true)
      @normalize_path = normalize_path

      @path =
        if normalize_path?
          normalize_path(repository_path)
        else
          repository_path
        end
    end

    private

    # true if the path should be expanded and converted to a absolute, real path
    # @return [Boolean]
    # @api private
    def normalize_path? = @normalize_path

    # Expand and convert the given path to an absolute, real path
    #
    # @example Expand the path
    #   normalize_path('~/repository.git') #=> '/Users/james/repository.git'
    #
    # @example Convert to an absolute path
    #   File.chdir('/User/james/repository/.git')
    #   normalize_path('.') #=> '/User/james/repository/.git'
    #
    # @param path [String] the path to normalize
    #
    # @return [String]
    #
    # @api private
    def normalize_path(path)
      raise ArgumentError, "Directory '#{path}' does not exist." unless File.directory?(path)

      File.realpath(File.expand_path(path))
    end
  end
end
