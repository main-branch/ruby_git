# frozen_string_literal: true

module RubyGit
  module Status
    # Represents git stash information
    #
    # @api private
    class StashInfo
      # @attribute [rw] count
      #
      # The number of stashed changes
      #
      # @example
      #   stash_info.count #=> 3
      #
      # @return [Integer] stash count
      #
      # @api private
      attr_accessor :count

      # Initialize a new stash info object
      #
      # @param count [Integer] number of stashed changes
      #
      # @api private
      def initialize(count)
        @count = count
      end

      # Check if there are stashed changes
      #
      # @return [Boolean] true if there are stashed changes
      #
      # @api private
      def stashed?
        @count.positive?
      end
    end
  end
end
