# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an ordinary changed file in git status
    #
    # @api public
    class SubmoduleStatus
      # Parse the submodule status string
      #
      # @example Parse submodule status
      #   SubmoduleStatus.parse('SC..')
      #     #=> #<SubmoduleStatus @commit_changed=true, @tracked_changes=false, @untracked_changes=false>
      #
      # @example If not a submodule
      #  SubmoduleStatus.parse('N..') #=> nil
      #
      # @param submodule_status [String] the submodule status string
      #
      # @return [SubmoduleStatus, nil] the parsed submodule status or nil
      #  if the status is not a submodule
      #
      def self.parse(submodule_status)
        return nil unless submodule_status[0] == 'S'

        new(
          commit_changed: (submodule_status[1] == 'C'),
          tracked_changes: (submodule_status[2] == 'M'),
          untracked_changes: (submodule_status[3] == 'U')
        )
      end

      # Initialize a new submodule status
      #
      # @example
      #   SubmoduleStatus.new(true, false, false)
      #
      # @param commit_changed [Boolean] the submodule commit changed
      # @param tracked_changes [Boolean] the tracked files in the submodule changed
      # @param untracked_changes [Boolean] the untracked files in the submodule changed
      #
      def initialize(commit_changed:, tracked_changes:, untracked_changes:)
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
