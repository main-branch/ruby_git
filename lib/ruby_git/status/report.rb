# frozen_string_literal: true

module RubyGit
  module Status
    # Represents a full git status report
    #
    # @api private
    class Report
      # @attribute [r] branch
      #
      # Information about the current git branch
      #
      # @example
      #   report.branch #=> #<RubyGit::Status::BranchInfo:0x00000001046bd488 ...>
      #
      # @return [RubyGit::Status::BranchInfo, nil] branch information or nil if not in a git repository
      #
      # @api private
      attr_reader :branch

      # @attribute [r] stash
      #
      # Information about git stash if available
      #
      # @example
      #   report.stash #=> #<RubyGit::Status::StashInfo:0x00000001046bd488 ...>
      #
      # @return [RubyGit::Status::StashInfo, nil] stash information or nil if no stash
      #
      # @api private
      attr_reader :stash

      # @attribute [r] entries
      #
      # All entries in the git status
      #
      # @example
      #   report.entries #=> [#<RubyGit::Status::OrdinaryEntry:0x00000001046bd488 ...>, ...]
      #
      # @return [Array<RubyGit::Status::Entry>] array of status entries
      #
      # @api private
      attr_reader :entries

      # Initialize a new status report
      #
      # @param branch [RubyGit::Status::BranchInfo, nil] branch information
      # @param stash [RubyGit::Status::StashInfo, nil] stash information
      # @param entries [Array<RubyGit::Status::Entry>] status entries
      #
      # @api private
      def initialize(branch, stash, entries)
        @branch = branch
        @stash = stash
        @entries = entries
      end

      # Find entries with the given staging status
      #
      # @param status [Symbol] staging status to filter by
      # @return [Array<RubyGit::Status::Entry>] entries with matching staging status
      #
      # @api private
      def staged(status = nil)
        return entries.select(&:staged?) if status.nil?

        entries.select { |e| e.staged? && e.staging_status == status }
      end

      # Find entries with the given worktree status
      #
      # @param status [Symbol] worktree status to filter by
      # @return [Array<RubyGit::Status::Entry>] entries with matching worktree status
      #
      # @api private
      def unstaged(status = nil)
        return entries.select(&:unstaged?) if status.nil?

        entries.select { |e| e.unstaged? && e.worktree_status == status }
      end

      # Find untracked files
      #
      # @return [Array<RubyGit::Status::Entry>] untracked entries
      #
      # @api private
      def untracked
        entries.select { |e| e.worktree_status == :untracked }
      end

      # Find ignored files
      #
      # @return [Array<RubyGit::Status::IgnoredEntry>] ignored entries
      #
      # @api private
      def ignored
        entries.select { |e| e.is_a?(IgnoredEntry) }
      end

      # Find unmerged entries
      #
      # @return [Array<RubyGit::Status::UnmergedEntry>] unmerged entries
      #
      # @api private
      def unmerged
        entries.select { |e| e.is_a?(UnmergedEntry) }
      end

      # Check if repository is clean (no changes)
      #
      # @return [Boolean] true if repository has no changes
      #
      # @api private
      def clean?
        entries.empty?
      end
    end
  end
end
