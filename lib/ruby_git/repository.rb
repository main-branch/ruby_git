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
    #
    def initialize(repository_path)
      @path = File.realpath(repository_path)
    end
  end
end
