# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an untracked file in git status
    #
    # @api private
    class UntrackedEntry < Entry
      # Parse a git status line to create an untracked entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UntrackedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split

        # Get the path (should be the second token after the '?' character)
        path = tokens[1]

        new(path)
      end

      # Get the worktree status
      #
      # @return [Symbol] always :untracked for untracked entries
      #
      # @api private
      def worktree_status
        :untracked
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for untracked entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always false for untracked entries since they are new files
      #
      # @api private
      def unstaged?
        false
      end
    end
  end
end
