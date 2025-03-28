# frozen_string_literal: true

module RubyGit
  module Status
    # Represents a full git status report
    #
    # @api public
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
      # @api public
      attr_reader :branch

      # @attribute [r] stash
      #
      # Information about git stash if available
      #
      # @example
      #   report.stash #=> #<RubyGit::Status::Stash:0x00000001046bd488 ...>
      #
      # @return [RubyGit::Status::Stash, nil] stash information or nil if no stash
      #
      # @api public
      attr_reader :stash

      # @attribute [r] entries
      #
      # All entries in the git status
      #
      # @example
      #   report.entries #=> [#<RubyGit::Status::Ordinary:0x00000001046bd488 ...>, ...]
      #
      # @return [Array<RubyGit::Status::Entry>] array of status entries
      #
      # @api public
      attr_reader :entries

      # Initialize a new status report
      #
      # @example
      #   Report.new(
      #     branch = Branch.new,
      #     stash = Stash.new,
      #     entries = [Ordinary.new, Renamed.new]
      #   )
      #
      # @param branch [RubyGit::Status::BranchInfo, nil] branch information
      # @param stash [RubyGit::Status::StashInfo, nil] stash information
      # @param entries [Array<RubyGit::Status::Entry>] status entries
      #
      def initialize(branch, stash, entries)
        @branch = branch
        @stash = stash
        @entries = entries
      end

      # The entries that are ignored
      #
      # @example
      #   report.ignored #=> [#<RubyGit::Status::IgnoredEntry ...>, ...]
      #
      # @return [Array<IgnoredEntry>]
      #
      def ignored
        entries.select(&:ignored?)
      end

      # The entries that are untracked
      #
      # @example
      #   report.untracked #=> [#<RubyGit::Status::UntrackedEntry ...>, ...]
      #
      # @return [Array<UntrackedEntry>]
      #
      def untracked
        entries.select(&:untracked?)
      end

      # The entries that have unstaged changes
      #
      # @example
      #   report.unstaged #=> [#<RubyGit::Status::OrdinaryEntry ...>, ...]
      #
      # @return [Array<UntrackedEntry, OrdinaryEntry, RenamedEntry>]
      #
      def unstaged
        entries.select(&:unstaged?)
      end

      # The entries that have staged changes
      #
      # @example
      #   report.staged #=> [#<RubyGit::Status::OrdinaryEntry ...>, ...]
      #
      # @return [Array<UntrackedEntry, OrdinaryEntry, RenamedEntry>]
      #
      def staged
        entries.select(&:staged?)
      end

      # The entries that have staged changes and no unstaged changes
      #
      # @example
      #   report.fully_staged #=> [#<RubyGit::Status::OrdinaryEntry ...>, ...]
      #
      # @return [Array<UntrackedEntry, OrdinaryEntry, RenamedEntry>]
      #
      def fully_staged
        entries.select(&:fully_staged?)
      end

      # The entries that represent merge conflicts
      #
      # @example
      #   report.unmerged #=> [#<RubyGit::Status::UnmergedEntry ...>, ...]
      #   report.merge_conflicts? #=> true
      #
      # @return [Array<UnmergedEntry>]
      #
      def unmerged
        entries.select(&:unmerged?)
      end

      # Are there any unmerged entries?
      #
      # @example
      #   report.merge_conflicts? #=> true
      #
      # @return [Boolean]
      #
      def merge_conflict?
        unmerged.any?
      end
    end
  end
end
