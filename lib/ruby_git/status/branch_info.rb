# frozen_string_literal: true

module RubyGit
  module Status
    # Represents git branch information
    #
    # @api private
    class BranchInfo
      # @attribute [rw] name
      #
      # The name of the current branch
      #
      # @example
      #   branch_info.name #=> 'main'
      #
      # @return [String, nil] branch name or nil if detached HEAD
      #
      # @api private
      attr_accessor :name

      # @attribute [rw] oid
      #
      # The object ID (hash) of the current commit
      #
      # @example
      #   branch_info.oid #=> 'abcdef1234567890'
      #
      # @return [String] commit hash
      #
      # @api private
      attr_accessor :oid

      # @attribute [rw] upstream
      #
      # The name of the upstream branch
      #
      # @example
      #   branch_info.upstream #=> 'origin/main'
      #
      # @return [String, nil] upstream branch name or nil if no upstream
      #
      # @api private
      attr_accessor :upstream

      # @attribute [rw] ahead
      #
      # Number of commits ahead of upstream
      #
      # @example
      #   branch_info.ahead #=> 2
      #
      # @return [Integer] number of commits ahead
      #
      # @api private
      attr_accessor :ahead

      # @attribute [rw] behind
      #
      # Number of commits behind upstream
      #
      # @example
      #   branch_info.behind #=> 3
      #
      # @return [Integer] number of commits behind
      #
      # @api private
      attr_accessor :behind

      # Initialize a new branch info object
      #
      # @param name [String, nil] branch name
      # @param oid [String, nil] object ID (commit hash)
      # @param upstream [String, nil] upstream branch name
      # @param ahead [Integer] commits ahead of upstream
      # @param behind [Integer] commits behind upstream
      #
      # @api private
      def initialize(name = nil, oid = nil, upstream = nil, ahead = nil, behind = nil)
        @name = name
        @oid = oid
        @upstream = upstream
        @ahead = ahead
        @behind = behind
      end

      # Check if the branch has an upstream configured
      #
      # @return [Boolean] true if upstream is configured
      #
      # @api private
      def upstream?
        !@upstream.nil?
      end

      # Check if HEAD is detached
      #
      # @return [Boolean] true if HEAD is detached
      #
      # @api private
      def detached?
        @name.nil?
      end
    end
  end
end
