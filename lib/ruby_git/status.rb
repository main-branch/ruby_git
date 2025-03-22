# frozen_string_literal: true

require_relative 'status/parser'
require_relative 'status/report'

module RubyGit
  # Git status command output representation
  module Status
    # Parse git status output and return a structured report
    #
    # @example
    #   output = `git status -u --porcelain=v2 --renames --branch --show-stash -z`
    #   status = RubyGit::Status.parse(output)
    #   status.branch.name #=> 'main'
    #
    # @param status_output [String] the raw output from git status command
    # @return [RubyGit::Status::Report] a structured representation of git status
    #
    # @api public
    def self.parse(status_output)
      Parser.parse(status_output)
    end
  end
end
