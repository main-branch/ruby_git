# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an ignored file in git status
    #
    # @api private
    class IgnoredEntry < Entry
      # Parse a git status line to create an ignored entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::IgnoredEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split

        # Get the path (should be the second token after the '!' character)
        path = tokens[1]

        new(path)
      end

      # Get the worktree status
      #
      # @return [Symbol] always :ignored for ignored entries
      #
      # @api private
      def worktree_status
        :ignored
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for ignored entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always false for ignored entries
      #
      # @api private
      def unstaged?
        false
      end
    end
  end
end
