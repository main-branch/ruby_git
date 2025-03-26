# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents a renamed file in git status
    #
    # @api public
    class RenamedEntry < Entry
      # @attribute [r] index_status
      #
      # The status in the staging area
      #
      # @example
      #   entry.index_status #=> :renamed
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

      # @attribute [r] head_mode
      #
      # The mode of the file in HEAD
      #
      # @example
      #   entry.head_mode #=> 0o100644
      #
      # @return [Integer] mode of the file in HEAD
      #
      # @api public
      attr_reader :head_mode

      # @attribute [r] index_mode
      #
      # The mode of the file in the index
      #
      # @example
      #   entry.index_mode #=> 0o100644
      #
      # @return [Integer] mode of the file in the index
      #
      # @api public
      attr_reader :index_mode

      # @attribute [r] worktree_mode
      #
      # The mode of the file in the worktree
      #
      # @example
      #   entry.worktree_mode #=> 0o100644
      #
      # @return [Integer] mode of the file in the worktree
      #
      # @api public
      attr_reader :worktree_mode

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
      #   entry.index_sha #=> 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'
      #
      # @return [String] SHA of this object in the index
      #
      # @api public
      attr_reader :index_sha

      # @attribute [r] operation
      #
      # The operation that was performed on the file: 'R' for  or 'C' for copy)
      #
      # @example
      #   entry.operation #=> 'R'
      #
      # @return [String] operation
      #
      # @api public
      attr_reader :operation

      # @attribute [r] similarity
      #
      # The similarity index between the original and renamed file
      #
      # @example
      #   entry.similarity #=> 95
      #
      # @return [Integer] similarity percentage
      #
      # @api public
      attr_reader :similarity_score

      # @attribute [r] path
      #
      # The path after the rename
      #
      # @example
      #   entry.path #=> 'lib/new_name.rb'
      #
      # @return [String]
      #
      # @api public
      attr_reader :path

      # @attribute [r] original_path
      #
      # The original path before rename
      #
      # @example
      #   entry.original_path #=> 'lib/old_name.rb'
      #
      # @return [String] original file path
      #
      # @api public
      attr_reader :original_path

      # Parse a git status line to create a renamed entry
      #
      # The line is expected to be in porcelain v2 format with NUL terminators.
      #
      # The format is as follows:
      #   2 <XY> <sub> <mH> <mI> <mW> <hH> <hI> <X><score> <path><sep><origPath>
      #
      # @example
      #   line = '2 RM N... 100644 100644 100644 d670460b4b4aece5915caf5c68d12f560a9fe3e4 ' \
      #     \d670460b4b4aece5915caf5c68d12f560a9fe3e4 50 lib/new_name.rb\0lib/old_name.rb'
      #   RenamedEntry.parse(line) #=> #<RubyGit::Status::RenamedEntry:0x00000001046bd488 ...>
      #
      # @param line [String] line from git status
      #
      # @return [RubyGit::Status::RenamedEntry] parsed entry
      #
      def self.parse(line) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        tokens = line.split(' ', 10)
        path, original_path = tokens[9].split("\0")

        new(
          index_status: Entry.status_to_symbol(tokens[1][0]),
          worktree_status: Entry.status_to_symbol(tokens[1][1]),
          submodule_status: SubmoduleStatus.parse(tokens[2]),
          head_mode: Integer(tokens[3], 8),
          index_mode: Integer(tokens[4], 8),
          worktree_mode: Integer(tokens[5], 8),
          head_sha: tokens[6],
          index_sha: tokens[7],
          operation: Entry.rename_operation_to_symbol(tokens[8][0]),
          similarity_score: tokens[8][1..].to_i,
          path: path,
          original_path: original_path
        )
      end

      # Initialize a new renamed entry
      #
      # @example
      #   RenamedEntry.new(
      #     index_status: :renamed,
      #     worktree_status: :modified,
      #     submodule_status: nil,
      #     head_mode: 0o100644,
      #     index_mode: 0o100644,
      #     worktree_mode: 0o100644,
      #     head_sha: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4',
      #     index_sha: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4',
      #     operation: :rename,
      #     similarity_score: 50,
      #     path: 'lib/new_name.rb',
      #     original_path: 'lib/old_name.rb'
      #   )
      #
      # @param index_status [Symbol] status in staging area
      # @param worktree_status [Symbol] status in worktree
      # @param submodule_status [SubmoduleStatus, nil] submodule status or nil
      # @param head_mode [Integer] mode of the file in HEAD
      # @param index_mode [Integer] mode of the file in the index
      # @param worktree_mode [Integer] mode of the file in the worktree
      # @param head_sha [String] SHA of this object in HEAD
      # @param index_sha [String] SHA of this object in the index
      # @param operation [Symbol] operation that was performed on the file
      # @param similarity_score [Integer] similarity index between the original and renamed file
      # @param path [String] new file path
      # @param original_path [String] original file path
      #
      def initialize( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        index_status:, worktree_status:,
        submodule_status:,
        head_mode:, index_mode:, worktree_mode:,
        head_sha:, index_sha:,
        operation:, similarity_score:,
        path:, original_path:
      )
        super(path)

        @index_status = index_status
        @worktree_status = worktree_status
        @submodule_status = submodule_status
        @head_mode = head_mode
        @index_mode = index_mode
        @worktree_mode = worktree_mode
        @head_sha = head_sha
        @index_sha = index_sha
        @operation = operation
        @similarity = similarity_score
        @original_path = original_path
      end
    end
  end
end
