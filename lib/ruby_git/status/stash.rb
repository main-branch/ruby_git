# frozen_string_literal: true

module RubyGit
  module Status
    # Represents git stash information
    #
    # @api public
    class Stash
      # @attribute [rw] count
      #
      # The number of stashed changes
      #
      # @example
      #   stash.count #=> 3
      #
      # @return [Integer] stash count
      #
      # @api public
      attr_accessor :count

      # Initialize a new stash info object
      #
      # @example
      #   Stash.new(3)
      #
      # @param count [Integer] number of stashed changes
      #
      def initialize(count)
        @count = count
      end
    end
  end
end
