# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents a renamed file in git status
    #
    # @api private
    class RenamedEntry < Entry
      # @attribute [r] staging_status
      #
      # The status in the staging area
      #
      # @example
      #   entry.staging_status #=> :renamed
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

      # @attribute [r] original_path
      #
      # The original path before rename
      #
      # @example
      #   entry.original_path #=> 'lib/old_name.rb'
      #
      # @return [String] original file path
      #
      # @api private
      attr_reader :original_path

      # @attribute [r] similarity
      #
      # The similarity index between the original and renamed file
      #
      # @example
      #   entry.similarity #=> 95
      #
      # @return [Integer] similarity percentage
      #
      # @api private
      attr_reader :similarity

      # Parse a git status line to create a renamed entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::RenamedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split
        xy = tokens[1]

        # Extract and parse the status codes
        x_status = Entry.status_to_symbol(xy[0])
        y_status = Entry.status_to_symbol(xy[1])

        # Find the similarity token (starts with R followed by digits)
        similarity_index = tokens.find_index { |t| t.match(/^R\d+$/) }
        similarity = similarity_index ? tokens[similarity_index].sub('R', '').to_i : 0

        # Determine paths - look for tokens that appear to be file paths
        # In most cases, these will be the last two tokens
        original_path = tokens[-2]
        new_path = tokens[-1]

        new(new_path, original_path, x_status, y_status, similarity)
      end

      # Initialize a new renamed entry
      #
      # @param path [String] new file path
      # @param original_path [String] original file path
      # @param staging_status [Symbol] status in staging area
      # @param worktree_status [Symbol] status in worktree
      # @param similarity [Integer] similarity percentage
      #
      # @api private
      def initialize(path, original_path, staging_status, worktree_status, similarity)
        super(path)
        @original_path = original_path
        @staging_status = staging_status
        @worktree_status = worktree_status
        @similarity = similarity
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] true if staged
      #
      # @api private
      def staged?
        @staging_status == :renamed
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] true if unstaged
      #
      # @api private
      def unstaged?
        @worktree_status != :unmodified
      end
    end
  end
end
