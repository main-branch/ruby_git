# frozen_string_literal: true

require 'ruby_git/version'
require 'ruby_git/file_helpers'
require 'ruby_git/git_binary'

# RubyGit is an object-oriented wrapper for the `git` command line tool for
# working with Worktrees and Repositories. It tries to make more sense out
# of the Git command line.
#
# @api public
#
module RubyGit
  # Return information about the git binary used by this library
  #
  # Use this object to set the path to the git binary to use or to see the
  # path being used.
  #
  # @example Setting the git binary path
  #    RubyGit.git.path = '/usr/local/bin/git'
  #
  # @return [RubyGit::GitBinary]
  #
  def self.git
    (@git ||= RubyGit::GitBinary.new)
  end
end
