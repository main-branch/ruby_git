# frozen_string_literal: true

require_relative 'entry'
require_relative 'submodule_status'

module RubyGit
  module Status
    # Represents an ordinary changed file in git status
    #
    # @api public
    class OrdinaryEntry < Entry
      # @attribute [r] index_status
      #
      # The status in the staging area
      #
      # @example
      #   entry.index_status #=> :modified
      #
      # @return [Symbol] staging status
      #
      # @api public
      attr_reader :index_status

      # @attribute [r] worktree_status
      #
      # The status in the worktree
      #
      # @example
      #   entry.worktree_status #=> :modified
      #
      # @return [Symbol] worktree status
      #
      # @api public
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
      # @api public
      attr_reader :submodule_status

      # @attribute [r] head_sha
      #
      # The SHA of this object in HEAD
      #
      # @example
      #   entry.head_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String] SHA of this object in HEAD
      #
      # @api public
      attr_reader :head_sha

      # @attribute [r] index_sha
      #
      # The SHA of this object in the index
      #
      # @example
      #  entry.index_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String] SHA of this object in the index
      #
      # @api public
      attr_reader :index_sha

      # @attribute [r] head_mode
      #
      # The file mode in HEAD
      #
      # @example
      #   entry.head_mode #=> 0o100644
      #
      # @return [Integer] file mode in HEAD
      #
      # @api private
      attr_reader :head_mode

      # @attribute [r] index_mode
      #
      # The file mode in the index
      #
      # @example
      #   entry.index_mode #=> 0o100644
      #
      # @return [Integer] file mode in the index
      #
      # @api private
      attr_reader :index_mode

      # @attribute [r] worktree_mode
      #
      # The file mode in the worktree
      #
      # @example
      #   entry.worktree_mode #=> 0o100644
      #
      # @return [Integer] file mode in the worktree
      #
      # @api private
      attr_reader :worktree_mode

      # Parse an ordinary change line of git status output
      #
      # The line is expected to be in porcelain v2 format with NUL terminators.
      #
      # The format is as follows:
      # 1 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <path>
      #
      # @example
      #   line = '1 M N... 100644 100644 100644 d670460b4b4aece5915caf5c68d12f560a9fe3e4 ' \
      #     \d670460b4b4aece5915caf5c68d12f560a9fe3e4 lib/example.rb'
      #   OrdinaryEntry.parse(line) #=> #<RubyGit::Status::OrdinaryEntry:0x00000001046bd488 ...>
      #
      # @param line [String] line from git status
      #
      # @return [RubyGit::Status::OrdinaryEntry] parsed entry
      #
      def self.parse(line) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        tokens = line.split

        new(
          index_status: Entry.status_to_symbol(tokens[1][0]),
          worktree_status: Entry.status_to_symbol(tokens[1][1]),
          submodule_status: SubmoduleStatus.parse(tokens[2]),
          head_mode: Integer(tokens[3], 8),
          index_mode: Integer(tokens[4], 8),
          worktree_mode: Integer(tokens[5], 8),
          head_sha: tokens[6],
          index_sha: tokens[7],
          path: tokens[8]
        )
      end

      # Initialize a new ordinary entry
      #
      # @example
      #   path = 'lib/example.rb'
      #   index_status = :modified
      #   worktree_status = :modified
      #   submodule_status = nil
      #   worktree_mode = 0o100644
      #   index_mode = 0o100644
      #   head_mode = 0o100644
      #   head_sha = 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #   index_sha = 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #   OrdinaryEntry.new(
      #     path:, index_status:, worktree_status:, submodule_status:,
      #     worktree_mode:, index_mode:, head_mode:, head_sha:, index_sha:
      #   )
      #
      # @param path [String] file path
      # @param index_status [Symbol] status in staging area
      # @param worktree_status [Symbol] status in worktree
      # @param submodule_status [SubmoduleStatus, nil] submodule status if applicable
      # @param worktree_mode [Integer] file mode in worktree
      # @param index_mode [Integer] file mode in staging area
      # @param head_mode [Integer] file mode in HEAD
      #
      def initialize( # rubocop:disable Metrics/ParameterLists
        path:,
        index_status:, worktree_status:,
        submodule_status:,
        head_mode:, index_mode:, worktree_mode:,
        head_sha:, index_sha:
      )
        super(path)
        @index_status = index_status
        @worktree_status = worktree_status
        @submodule_status = submodule_status
        @worktree_mode = worktree_mode
        @index_mode = index_mode
        @head_mode = head_mode
        @head_sha = head_sha
        @index_sha = index_sha
      end

      # Does the entry have unstaged changes in the worktree?
      #
      # * An entry can have both staged and unstaged changes
      # * All untracked entries are considered unstaged
      #
      # @example
      #   entry.ignored? #=> false
      # @return [Boolean]
      def unstaged?
        worktree_status != :unmodified
      end

      # Does the entry have staged changes in the index?
      #
      # * An entry can have both staged and unstaged changes
      #
      # @example
      #   entry.ignored? #=> false
      # @return [Boolean]
      def staged?
        index_status != :unmodified
      end
    end
  end
end
