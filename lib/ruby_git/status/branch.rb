# frozen_string_literal: true

module RubyGit
  module Status
    # Represents git branch information
    #
    # @api public
    class Branch
      # @attribute [rw] name
      #
      # The name of the current branch
      #
      # @example
      #   branch.name #=> 'main'
      #
      # @return [String, nil] branch name or nil if detached HEAD
      #
      # @api public
      attr_accessor :name

      # @attribute [rw] oid
      #
      # The object ID (hash) of the current commit
      #
      # @example
      #   branch.oid #=> 'abcdef1234567890'
      #
      # @return [String] commit hash
      #
      # @api public
      attr_accessor :oid

      # @attribute [rw] upstream
      #
      # The name of the upstream branch
      #
      # @example
      #   branch.upstream #=> 'origin/main'
      #
      # @return [String, nil] upstream branch name or nil if no upstream
      #
      # @api public
      attr_accessor :upstream

      # @attribute [rw] ahead
      #
      # Number of commits ahead of upstream
      #
      # @example
      #   branch.ahead #=> 2
      #
      # @return [Integer] number of commits ahead
      #
      # @api public
      attr_accessor :ahead

      # @attribute [rw] behind
      #
      # Number of commits behind upstream
      #
      # @example
      #   branch.behind #=> 3
      #
      # @return [Integer] number of commits behind
      #
      # @api public
      attr_accessor :behind

      # Check if the branch has an upstream configured
      #
      # @example
      #   branch.upstream? #=> true
      #
      # @return [Boolean] true if upstream is configured
      #
      def upstream?
        !@upstream.nil?
      end

      # Check if HEAD is detached
      #
      # @example
      #   branch.detached? #=> true
      #
      # @return [Boolean] true if HEAD is detached
      #
      def detached?
        @name.nil?
      end
    end
  end
end
