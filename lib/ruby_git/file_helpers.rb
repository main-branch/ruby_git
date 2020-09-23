# frozen_string_literal: true

module RubyGit
  # A namespace for several file utility methods that I wish were part of FileUtils.
  #
  # @api public
  #
  module FileHelpers
    # Cross platform way to find an executable file within a list of paths
    #
    # Works for both Linux/Unix and Windows.
    #
    # @example Searching over the PATH for a command
    #   path = FileUtils.which('git')
    #
    # @example Overriding the default PATH
    #   path = FileUtils.which('git', ['/usr/bin', '/usr/local/bin'])
    #
    # @param [String] cmd The basename of the executable file to search for
    # @param [Array<String>] paths The list of directories to search for basename in
    # @param [Array<String>] exts The list of extensions that indicate that a file is executable
    #
    # `exts` is for Windows. Other platforms should accept the default.
    #
    # @return [Pathname,nil] The path to the first executable file found on the path or
    #   nil an executable file was not found.
    #
    def self.which(
      cmd,
      paths: ENV['PATH'].split(File::PATH_SEPARATOR),
      exts: (ENV['PATHEXT']&.split(';') || [''])
    )
      raise 'PATH is not set' unless ENV.keys.include?('PATH')

      paths
        .product(exts)
        .map { |path, ext| Pathname.new(File.join(path, "#{cmd}#{ext}")) }
        .reject { |path| path.directory? || !path.executable? }
        .find { |exe_path| !exe_path.directory? && exe_path.executable? }
    end
  end
end
