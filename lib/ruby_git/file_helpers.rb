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
    # @example Searching over the ENV['PATH'] for a command
    #   RubyGit::FileHelpers.which('git')
    #    => #<Pathname:/usr/local/bin/git>
    #
    # @example Overriding the default path (which is ENV['PATH'])
    #   RubyGit::FileHelpers.which('git', path: '/usr/bin:/usr/local/bin')
    #    => #<Pathname:/usr/bin/git>
    #
    # @example On Windows
    #   RubyGit::FileHelpers.which('git', path: 'C:\Windows\System32;C:\Program Files\Git\bin')
    #    => #<Pathname:C:/Program Files/Git/bin/git.exe>
    #
    # @param [String] cmd_basename The basename of the executable file to search for
    #
    # @param [String] path The list of directories to search for basename in given as a String
    #
    # The default value is ENV['PATH']. The string is split on `File::PATH_SEPARATOR`. If the `path` is an
    # empty string, RuntimeError is raised.
    #
    # @param [String] path_ext The list of extensions to check for
    #
    # The default value is ENV['PATHEXT'].  The string is split on `File::PATH_SEPARATOR`. `path_ext` may
    # be an empty string to indicate no extensions should be added to `cmd` when searching the `path`.
    #
    # Typically this is only used for Windows to specify binary file extensions such as `.EXE;.BAT;.CMD`
    #
    # @return [Pathname,nil] The path to the first executable file found on the path or
    #   nil an executable file was not found.
    #
    def self.which(cmd_basename, path: ENV['PATH'], path_ext: ENV['PATHEXT'])
      raise 'path can not be nil or empty' if path.nil? || path.empty?

      split_path(path)
        .product(split_path(path_ext))
        .each do |path_dir, ext|
          cmd_pathname = File.join(path_dir, "#{cmd_basename}#{ext}")
          return Pathname.new(cmd_pathname) if !File.directory?(cmd_pathname) && File.executable?(cmd_pathname)
        end
      nil
    end

    # Split the path string on the File::PATH_SEPARATOR
    #
    # @example
    #   File::PATH_SEPARATOR
    #    => ":"
    #   FileHelpers.split_path('/bin:/usr/local/bin')
    #    => ["/bin", "/usr/local/bin"]
    #
    # @param [String] path The path string to split
    #
    # @return [Array<String>] the split path or [''] if the path was nil
    #
    def self.split_path(path)
      path&.split(File::PATH_SEPARATOR) || ['']
    end
  end
end
