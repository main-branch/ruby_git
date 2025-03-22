# frozen_string_literal: true

module RubyGit
  module Status
    # Base class for git status entries
    #
    # @api private
    class Entry
      # Status code mapping to symbols
      #
      # @api private
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

      # @attribute [r] path
      #
      # The path of the file
      #
      # @example
      #   entry.path #=> 'lib/example.rb'
      #
      # @return [String] file path
      #
      # @api private
      attr_reader :path

      # Initialize a new entry
      #
      # @param path [String] file path
      #
      # @api private
      def initialize(path)
        @path = path
      end

      # Convert a status code to a symbol
      #
      # @param code [String] status code
      # @return [Symbol] status as symbol
      #
      # @api private
      def self.status_to_symbol(code)
        STATUS_CODES[code.to_sym] || :unknown
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] true if staged
      #
      # @api private
      def staged? = false

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] true if unstaged
      #
      # @api private
      def unstaged? = false

      # Get the staging status
      #
      # @return [Symbol, nil] staging status symbol or nil if not applicable
      #
      # @api private
      def staging_status = nil

      # Get the worktree status
      #
      # @return [Symbol, nil] worktree status symbol or nil if not applicable
      #
      # @api private
      def worktree_status = nil
    end
  end
end
