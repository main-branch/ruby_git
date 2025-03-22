# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an ordinary changed file in git status
    #
    # @api public
    class SubmoduleStatus
      def self.parse(submodule_status)
        return nil unless submodule_status[0] == 'S'

        commit_changed = (submodule_status[1] == 'C')
        tracked_changes = (submodule_status[2] == 'M')
        untracked_changes = (submodule_status[3] == 'U')

        new(commit_changed, tracked_changes, untracked_changes)
      end

      def initialize(commit_changed, tracked_changes, untracked_changes)
        @commit_changed = commit_changed
        @tracked_changes = tracked_changes
        @untracked_changes = untracked_changes
      end

      # @attribute [r] commit_changed?
      #
      # The submodule commit changed
      #
      # @example
      #   submodule_status.commit_changed? #=> true
      #
      # @return [Boolean]
      #
      # @api public
      def commit_changed? = @commit_changed

      # @attribute [r] tracked_changes?
      #
      # The one or more tracked files in the submodule changed
      #
      # @example
      #   submodule_status.tracked_changes? #=> true
      #
      # @return [Boolean]
      #
      def tracked_changes? = @tracked_changes

      # @attribute [r] untracked_changes?
      #
      # The one or more untracked files in the submodule changed
      #
      # @example
      #   submodule_status.untracked_changes? #=> true
      #
      # @return [Boolean]
      #
      def untracked_changes? = @untracked_changes
    end
  end
end
