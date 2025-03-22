# frozen_string_literal: true

require_relative 'entry'
require_relative 'submodule_status'

module RubyGit
  module Status
    # Represents an ordinary changed file in git status
    #
    # @api private
    class OrdinaryEntry < Entry
      # @attribute [r] staging_status
      #
      # The status in the staging area
      #
      # @example
      #   entry.staging_status #=> :modified
      #
      # @return [Symbol] staging status
      #
      # @api private
      attr_reader :staging_status

      # @attribute [r] worktree_status
      #
      # The status in the worktree
      #
      # @example
      #   entry.worktree_status #=> :modified
      #
      # @return [Symbol] worktree status
      #
      # @api private
      attr_reader :worktree_status

      # @attribute [r] submodule_status
      #
      # The submodule status if the entry is a submodule
      #
      # @example
      #   entry.submodule #=> 'N...'
      #
      # @return [SubmoduleStatus, nil] submodule status or nil if not a submodule
      #
      # @api private
      attr_reader :submodule_status

      # Parse a git status line to create an ordinary entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::OrdinaryEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split
        xy = tokens[1]

        # Extract and parse the status codes
        x_status = Entry.status_to_symbol(xy[0])
        y_status = Entry.status_to_symbol(xy[1])

        # Get submodule status if present
        # In porcelain v2, submodule status is in format [xy] [submodule_status]
        # where submodule_status is right after the xy status codes
        submodule_status = SubmoduleStatus.parse(tokens[2])

        # Get the path
        path = tokens[8] || tokens[7]

        new(path, x_status, y_status, submodule_status)
      end

      # Initialize a new ordinary entry
      #
      # @param path [String] file path
      # @param staging_status [Symbol] status in staging area
      # @param worktree_status [Symbol] status in worktree
      # @param submodule_status [SubmoduleStatus, nil] submodule status if applicable
      #
      # @api private
      def initialize(path, staging_status, worktree_status, submodule_status)
        super(path)
        @staging_status = staging_status
        @worktree_status = worktree_status
        @submodule_status = submodule_status
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] true if staged
      #
      # @api private
      def staged?
        @staging_status != :unmodified && @staging_status != :untracked && @staging_status != :ignored
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] true if unstaged
      #
      # @api private
      def unstaged?
        @worktree_status != :unmodified && @worktree_status != :untracked && @worktree_status != :ignored
      end

      # Check if the entry is a submodule
      #
      # @return [Boolean] true if submodule
      #
      # @api private
      def submodule?
        !@submodule_status.nil?
      end

      # Check if the entry is untracked
      #
      # @return [Boolean] true if untracked
      #
      # @api private
      def untracked?
        @worktree_status == :untracked
      end
    end
  end
end
