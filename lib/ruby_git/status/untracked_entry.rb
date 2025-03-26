# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an untracked file in git status
    #
    # @api public
    class UntrackedEntry < Entry
      # Parse a git status line to create an untracked entry
      #
      # @example
      #   UntrackedEntry.parse('?? lib/example.rb') #=> #<RubyGit::Status::UntrackedEntry:0x00000001046bd488 ...>
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UntrackedEntry] parsed entry
      #
      def self.parse(line)
        tokens = line.split(' ', 2)
        new(path: tokens[1])
      end

      # Initialize with the path
      #
      # @example
      #   UntrackedEntry.new(path: 'file.txt')
      #
      # @param path [String] the path of the untracked file
      #
      def initialize(path:)
        super(path)
      end
    end
  end
end
