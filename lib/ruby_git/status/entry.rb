# frozen_string_literal: true

module RubyGit
  module Status
    # Base class for git status entries
    #
    # @api public
    class Entry
      # Status code mapping to symbols
      STATUS_CODES = {
        '.': :unmodified,
        M: :modified,
        T: :type_changed,
        A: :added,
        D: :deleted,
        R: :renamed,
        C: :copied,
        U: :updated_but_unmerged,
        '?': :untracked,
        '!': :ignored
      }.freeze

      # Rename operation mapping to symbols
      RENAME_OPERATIONS = {
        'R' => :rename
        # git status doesn't actually try to detect copies
        # 'C' => :copy
      }.freeze

      # @attribute [r] path
      #
      # The path of the file
      #
      # @example
      #   entry.path #=> 'lib/example.rb'
      #
      # @return [String] file path
      #
      attr_reader :path

      # Initialize a new entry
      #
      # @example
      #   Entry.new('lib/example.rb')
      #
      # @param path [String] file path
      #
      def initialize(path)
        @path = path
      end

      # Convert a status code to a symbol
      #
      # @example
      #   Entry.status_to_symbol('M') #=> :modified
      #
      # @param code [String] status code
      # @return [Symbol] status as symbol
      #
      def self.status_to_symbol(code)
        STATUS_CODES[code.to_sym] || :unknown
      end

      # Convert a rename operation to a symbol
      #
      # @example
      #   Entry.rename_operation_to_symbol('R') #=> :rename
      #
      # @param code [String] the operation code
      # @return [Symbol] operation as symbol
      #
      def self.rename_operation_to_symbol(code)
        RENAME_OPERATIONS[code] || :unknown
      end

      # Get the staging status
      #
      # @example
      #   entry.staging_status #=> :modified
      #
      # @return [Symbol, nil] staging status symbol or nil if not applicable
      #
      def index_status = nil

      # Get the worktree status
      #
      # @example
      #   entry.worktree_status #=> :unmodified
      #
      # @return [Symbol, nil] worktree status symbol or nil if not applicable
      #
      def worktree_status = nil

      # Is the entry an ignored file?
      #
      # * Ignored entries are not considered untracked
      #
      # @example
      #   entry.ignored? #=> false
      #
      # @return [Boolean]
      #
      def ignored? = false

      # Is the entry an untracked file?
      #
      # * Ignored entries are not considered untracked
      #
      # @example
      #   entry.ignored? #=> false
      #
      # @return [Boolean]
      #
      def untracked? = false

      # Does the entry have unstaged changes in the worktree?
      #
      # * An entry can have both staged and unstaged changes
      # * All untracked entries are considered unstaged
      #
      # @example
      #   entry.ignored? #=> false
      #
      # @return [Boolean]
      #
      def unstaged? = false

      # Does the entry have staged changes in the index?
      #
      # * An entry can have both staged and unstaged changes
      #
      # @example
      #   entry.ignored? #=> false
      #
      # @return [Boolean]
      #
      def staged? = false

      # Does the entry have staged changes in the index with no unstaged changes?
      #
      # * An entry can have both staged and unstaged changes
      #
      # @example
      #   entry.fully_staged? #=> false
      #
      # @return [Boolean]
      #
      def fully_staged? = staged? && !unstaged?

      # Does the entry represent a merge conflict?
      #
      # * Merge conflicts are not considered untracked, staged or unstaged
      #
      # @example
      #   entry.conflict? #=> false
      #
      # @return [Boolean]
      #
      def unmerged? = false
    end
  end
end
