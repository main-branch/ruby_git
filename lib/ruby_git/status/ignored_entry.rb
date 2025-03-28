# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an ignored file in git status
    #
    # @api public
    class IgnoredEntry < Entry
      # Parse a git status line to create an ignored entry
      #
      # @example
      #   IgnoredEntry.parse('!! lib/example.rb') #=> #<RubyGit::Status::IgnoredEntry:0x00000001046bd488 ...>
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::IgnoredEntry] parsed entry
      #
      def self.parse(line)
        tokens = line.split(' ', 2)
        new(path: tokens[1])
      end

      # Initialize with the path
      #
      # @example
      #   IgnoredEntry.new(path: 'lib/example.rb')
      #
      # @param path [String] file path
      #
      def initialize(path:)
        super(path)
      end

      # Is the entry an ignored file?
      # @example
      #   entry.ignored? #=> false
      # @return [Boolean]
      def ignored?
        true
      end
    end
  end
end
