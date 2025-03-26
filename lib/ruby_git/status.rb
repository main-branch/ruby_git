# frozen_string_literal: true

require_relative 'status/branch'
require_relative 'status/entry'
require_relative 'status/ignored_entry'
require_relative 'status/ordinary_entry'
require_relative 'status/parser'
require_relative 'status/renamed_entry'
require_relative 'status/report'
require_relative 'status/stash'
require_relative 'status/submodule_status'
require_relative 'status/unmerged_entry'
require_relative 'status/untracked_entry'

module RubyGit
  # The working tree status
  module Status
    # Parse output of `git status` and return a structured report
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
