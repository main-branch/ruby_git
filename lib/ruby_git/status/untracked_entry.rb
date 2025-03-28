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

      # Is the entry an untracked file?
      # @example
      #   entry.ignored? #=> false
      # @return [Boolean]
      def untracked? = true

      # Does the entry have unstaged changes in the worktree?
      #
      # * An entry can have both staged and unstaged changes
      # * All untracked entries are considered unstaged
      #
      # @example
      #   entry.ignored? #=> false
      # @return [Boolean]
      def unstaged? = true
    end
  end
end
