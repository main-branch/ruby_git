# frozen_string_literal: true

require_relative 'report'
require_relative 'branch_info'
require_relative 'stash_info'
require_relative 'entry'
require_relative 'ordinary_entry'
require_relative 'renamed_entry'
require_relative 'unmerged_entry'
require_relative 'ignored_entry'
require_relative 'untracked_entry'

module RubyGit
  module Status
    # Parses the git status porcelain v2 format output
    #
    # @api private
    class Parser
      # Parse the git status output and return a report object
      #
      # @param status_output [String] raw git status output
      # @return [RubyGit::Status::Report] parsed status report
      #
      # @api private
      def self.parse(status_output)
        new(status_output).parse
      end

      # Initialize with the status output
      #
      # @param status_output [String] raw git status output
      #
      # @api private
      def initialize(status_output)
        @status_output = status_output
        @entries = []
        @branch_info = nil
        @stash_info = StashInfo.new(0)
      end

      # Parse the git status output
      #
      # @return [RubyGit::Status::Report] parsed status report
      #
      # @api private
      def parse
        lines = @status_output.split("\u0000")
        process_lines(lines)

        Report.new(@branch_info, @stash_info, @entries)
      end

      LINE_PARSER_FACTORY = {
        '1' => ->(line) { OrdinaryEntry.parse(line) },
        '2' => ->(line) { RenamedEntry.parse(line) },
        'u' => ->(line) { UnmergedEntry.parse(line) },
        '!' => ->(line) { IgnoredEntry.parse(line) },
        '?' => ->(line) { UntrackedEntry.parse(line) }
      }.freeze

      # Process the split lines of git status output
      #
      # @param lines [Array<String>] lines from git status output
      # @return [void]
      #
      # @api private
      def process_lines(lines)
        # Use the LINE_PARSER_FACTORY to parse each line
        # based on the first character like the code below
        lines.each do |line|
          next if line.empty?

          if line.start_with?('#')
            parse_header_line(line)
          else
            @entries << LINE_PARSER_FACTORY[line[0]].call(line)
          end
        end
      end

      # Parse a header line (starts with #)
      #
      # @param line [String] header line from git status
      #
      # @api private
      def parse_header_line(line)
        tokens = line.split(' ')
        header_type = tokens[1]

        process_header(header_type, tokens)
      end

      private

      # Process a specific header type with its tokens
      #
      # @param header_type [String] type of header
      # @param tokens [Array<String>] tokens from header line
      # @return [void]
      #
      # @api private
      def process_header(header_type, tokens)
        case header_type
        when 'branch.head'
          @branch_info ||= BranchInfo.new
          @branch_info.name = tokens[2] unless tokens[2] == '(detached)'
        when 'branch.oid'
          @branch_info ||= BranchInfo.new
          @branch_info.oid = tokens[2] unless tokens[2] == '(initial)'
        when 'branch.upstream'
          @branch_info ||= BranchInfo.new
          @branch_info.upstream = tokens[2]
        when 'branch.ab'
          @branch_info ||= BranchInfo.new
          @branch_info.ahead = tokens[2].sub('+', '').to_i
          @branch_info.behind = tokens[3].sub('-', '').to_i
        when 'stash'
          @stash_info.count = tokens[2].to_i
        end
      end
    end
  end
end
