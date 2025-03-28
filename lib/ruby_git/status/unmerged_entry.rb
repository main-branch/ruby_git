# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an unmerged file in git status
    #
    # @api public
    class UnmergedEntry < Entry
      # @attribute [r] conflict_type
      #
      # The type of merge conflict
      #
      # @example
      #   entry.conflict_type #=> :both_deleted
      #
      # @see RubyGit::Status::UnmergedEntry::CONFLICT_TYPES
      #
      # @return [Symbol]
      #
      # @api public
      attr_reader :conflict_type

      # @attribute [r] submodule_status
      #
      # The submodule status if the entry is a submodule or nil
      #
      # @example
      #   entry.submodule #=> 'N...'
      #
      # @return [SubmoduleStatus, nil]
      #
      # @api public
      attr_reader :submodule_status

      # @attribute [r] base_mode
      #
      # The mode of the file in the base
      #
      # @example
      #   entry.base_mode #=> 0o100644
      #
      # @return [Integer]
      #
      # @api public
      attr_reader :base_mode

      # @attribute [r] our_mode
      #
      # The mode of the file in our branch
      #
      # @example
      #   entry.our_mode #=> 0o100644
      #
      # @return [Integer]
      #
      # @api public
      attr_reader :our_mode

      # @attribute [r] their_mode
      #
      # The mode of the file in their branch
      #
      # @example
      #  entry.their_mode #=> 0o100644
      #
      # @return [Integer]
      #
      # @api public
      attr_reader :their_mode

      # @attribute [r] worktree_mode
      #
      # The mode of the file in the worktree
      #
      # @example
      #   entry.worktree_mode #=> 0o100644
      #
      # @return [Integer]
      #
      # @api public
      attr_reader :worktree_mode

      # @attribute [r] base_sha
      #
      # The SHA of the file in the base
      #
      # @example
      #   entry.base_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String]
      #
      # @api public
      attr_reader :base_sha

      # @attribute [r] our_sha
      #
      # The SHA of the file in our branch
      #
      # @example
      #   entry.our_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String]
      #
      # @api public
      attr_reader :our_sha

      # @attribute [r] their_sha
      #
      # The SHA of the file in their branch
      #
      # @example
      #   entry.their_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String]
      #
      # @api public
      attr_reader :their_sha

      # @attribute [r] path
      #
      # The path of the file
      #
      # @example
      #   entry.path #=> 'lib/example.rb'
      #
      # @return [String]
      #
      # @api public
      attr_reader :path

      # Parse an unmerged change line of git status output
      #
      # The line is expected to be in porcelain v2 format with NUL terminators.
      #
      # The format is as follows:
      # u <XY> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path>
      #
      # @example
      #   line = 'uU N... 100644 100644 100644 100644 d670460b4b4aece5915caf5c68d12f560a9fe3e4 ' \
      #     'd670460b4b4aece5915caf5c68d12f560a9fe3e4 d670460b4b4aece5915caf5c68d12f560a9fe3e4 lib/example.rb'
      #   UnmergedEntry.parse(line) #=> #<RubyGit::Status::UnmergedEntry:0x00000001046bd488 ...>
      #
      # @param line [String] line from git status
      #
      # @return [RubyGit::Status::UnmergedEntry] parsed entry
      #
      def self.parse(line) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        tokens = line.split(' ', 11)

        new(
          conflict_type: conflict_code_to_type(tokens[1]),
          submodule_status: SubmoduleStatus.parse(tokens[2]),
          base_mode: Integer(tokens[3], 8),
          our_mode: Integer(tokens[4], 8),
          their_mode: Integer(tokens[5], 8),
          worktree_mode: Integer(tokens[6], 8),
          base_sha: tokens[7],
          our_sha: tokens[8],
          their_sha: tokens[9],
          path: tokens[10]
        )
      end

      # Maps the change code to a conflict type symbol
      CONFLICT_TYPES = {
        'DD' => :both_deleted,
        'AU' => :added_by_us,
        'UD' => :deleted_by_them,
        'UA' => :added_by_them,
        'DU' => :deleted_by_us,
        'AA' => :both_added,
        'UU' => :both_modified
      }.freeze

      # Convert conflict code to a symbol
      #
      # @example
      #   UnmergedEntry.conflict_code_to_type('DD') #=> :both_deleted
      #
      # @param code [String] conflict code
      # @return [Symbol] conflict type as symbol
      #
      def self.conflict_code_to_type(code)
        CONFLICT_TYPES[code] || :unknown
      end

      # Initialize a new unmerged entry
      #
      # @example
      #   UnmergedEntry.new(
      #     conflict_type: :both_deleted,
      #     submodule_status: nil,
      #     base_mode: 0o100644,
      #     our_mode: 0o100644,
      #     their_mode: 0o100644,
      #     worktree_mode: 0o100644,
      #     base_sha: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4',
      #     our_sha: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4',
      #     their_sha: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4',
      #     path: 'lib/example.rb'
      #   )
      #
      # @param conflict_type [Symbol] type of merge conflict
      # @param submodule_status [SubmoduleStatus, nil] submodule status if applicable
      # @param base_mode [Integer] mode of the file in the base
      # @param our_mode [Integer] mode of the file in our branch
      # @param their_mode [Integer] mode of the file in their branch
      # @param worktree_mode [Integer] mode of the file in the worktree
      # @param base_sha [String] SHA of the file in the base
      # @param our_sha [String] SHA of the file in our branch
      # @param their_sha [String] SHA of the file in their branch
      # @param path [String] file path
      #
      def initialize( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        conflict_type:,
        submodule_status:,
        base_mode:, our_mode:, their_mode:, worktree_mode:,
        base_sha:, our_sha:, their_sha:,
        path:
      )
        super(path)
        @conflict_type = conflict_type
        @submodule_status = submodule_status
        @base_mode = base_mode
        @our_mode = our_mode
        @their_mode = their_mode
        @worktree_mode = worktree_mode
        @base_sha = base_sha
        @our_sha = our_sha
        @their_sha = their_sha
        @path = path
      end

      # Does the entry represent a merge conflict?
      #
      # * Merge conflicts are not considered untracked, staged or unstaged
      #
      # @example
      #   entry.conflict? #=> false
      #
      # @return [Boolean]
      #
      def unmerged? = true
    end
  end
end
