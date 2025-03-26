# frozen_string_literal: true

require_relative 'report'
require_relative 'branch'
require_relative 'stash'
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
    # git status --porcelain=v2 -z \
    #   --untracked-files --ignored-files --renames \
    #   --ahead-behind --branch --show-stash
    #
    # @api public
    class Parser
      # Parse the git status output and return a report object
      #
      # @example
      #   status_output = `git status -u --porcelain=v2 --renames --branch --show-stash -z`
      #   report = RubyGit::Status::Parser.parse(status_output) #=> #<RubyGit::Status::Report>
      #
      # @param status_output [String] raw git status output
      #
      # @return [RubyGit::Status::Report] parsed status report
      #
      def self.parse(status_output)
        new(status_output).parse
      end

      # Create a new status output parser
      #
      # @example
      #    status_output = `git status -u --porcelain=v2 --renames --branch --show-stash -z`
      #    parser = RubyGit::Status::Parser.new(status_output)
      #
      # @param status_output [String] raw git status output
      #
      def initialize(status_output)
        @status_output = status_output
        @entries = []
        @branch = nil
        @stash = Stash.new(0)
      end

      # Parse the git status output
      #
      # @example
      #   status_output = `git status -u --porcelain=v2 --renames --branch --show-stash -z`
      #   parser = RubyGit::Status::Parser.new(status_output)
      #   parser.parse #=> #<RubyGit::Status::Report>
      #
      # @return [RubyGit::Status::Report] parsed status report
      #
      def parse
        process_lines(status_output_lines)

        Report.new(@branch, @stash, @entries)
      end

      # Define the parser for each line type
      LINE_PARSER_FACTORY = {
        '1' => ->(line) { OrdinaryEntry.parse(line) },
        '2' => ->(line) { RenamedEntry.parse(line) },
        'u' => ->(line) { UnmergedEntry.parse(line) },
        '!' => ->(line) { IgnoredEntry.parse(line) },
        '?' => ->(line) { UntrackedEntry.parse(line) }
      }.freeze

      private

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
      # @return [void]
      #
      # @api private
      def parse_header_line(line)
        tokens = line.split
        header_type = tokens[1]

        process_header(header_type, tokens)
      end

      # Split the status output into lines
      #
      # This is more complicated than a simple split because
      # the lines are NUL terminated but some entries have
      # also use NUL as a field separator (e.g. renamed entries).
      #
      # @return [Array<String>] split lines
      #
      # @api private
      #
      def status_output_lines
        parts = @status_output.split("\u0000")
        [].tap do |lines|
          until parts.empty?
            next_entry_type = parts.first[0]
            lines << parts.shift
            lines[-1] = "#{lines[-1]}\u0000#{parts.shift}" if next_entry_type == '2'
          end
        end
      end

      # Info from the status_output about the branch
      # @return [Branch]
      # @api private
      def branch = @branch ||= Branch.new

      # Info about the stashes about stashes
      # @return [Stash]
      # @api private
      attr_reader :stash

      # Branch name setter that handles detached HEAD
      # @param name [String] branch name
      # @return [void]
      # @api private
      def branch_name=(name)
        branch.name = name unless name == '(detached)'
      end

      # Branch oid setter that handles initial commit
      # @param oid [String] branch oid
      # @return [void]
      # @api private
      def branch_oid=(oid)
        branch.oid = oid unless oid == '(initial)'
      end

      # Branch upstream setter
      # @param upstream [String] branch upstream
      # @return [void]
      # @api private
      def branch_upstream=(upstream)
        branch.upstream = upstream
      end

      # Branch ahead setter that converts from string to integer
      # @param ahead [String] branch ahead
      # @return [void]
      # @api private
      def branch_ahead=(ahead)
        branch.ahead = ahead.sub('+', '').to_i
      end

      # Branch behind setter that converts from string to integer
      # @param behind [String] branch behind
      # @return [void]
      # @api private
      def branch_behind=(behind)
        branch.behind = behind.sub('-', '').to_i
      end

      # Process a specific header type with its tokens
      #
      # @param header_type [String] type of header
      # @param tokens [Array<String>] tokens from header line
      # @return [void]
      #
      # @api private
      def process_header(header_type, tokens)
        case header_type
        when 'branch.head' then self.branch_name = tokens[2]
        when 'branch.oid' then self.branch_oid = tokens[2]
        when 'branch.upstream' then self.branch_upstream = tokens[2]
        when 'branch.ab'
          self.branch_ahead = tokens[2]
          self.branch_behind = tokens[3]
        when 'stash' then stash.count = tokens[2].to_i
        end
      end
    end
  end
end
