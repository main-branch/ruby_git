# frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an unmerged file in git status
    #
    # @api private
    class UnmergedEntry < Entry
      # @attribute [r] stage_1
      #
      # Stage 1 (common ancestor) mode and object ID
      #
      # @example
      #   entry.stage_1 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 1 information or nil if not present
      #
      # @api private
      attr_reader :stage_1

      # @attribute [r] stage_2
      #
      # Stage 2 (ours) mode and object ID
      #
      # @example
      #   entry.stage_2 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 2 information or nil if not present
      #
      # @api private
      attr_reader :stage_2

      # @attribute [r] stage_3
      #
      # Stage 3 (theirs) mode and object ID
      #
      # @example
      #   entry.stage_3 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 3 information or nil if not present
      #
      # @api private
      attr_reader :stage_3

      # @attribute [r] conflict_type
      #
      # Type of merge conflict
      #
      # @example
      #   entry.conflict_type #=> :both_added
      #
      # @return [Symbol] conflict type
      #
      # @api private
      attr_reader :conflict_type

      # Parse a git status line to create an unmerged entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UnmergedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split(' ')

        # Extract conflict type (1st character after 'u')
        conflict_code = tokens[1][0]
        conflict_type = conflict_code_to_type(conflict_code)

        # Extract stage information
        stage_1 = extract_stage_info(tokens, 2) # 2, 3
        stage_2 = extract_stage_info(tokens, 4) # 4, 5
        stage_3 = extract_stage_info(tokens, 6) # 6, 7

        # Get the path
        path = tokens[8]

        new(path, conflict_type, stage_1, stage_2, stage_3)
      end

      # Convert conflict code to a symbol
      #
      # @param code [String] conflict code
      # @return [Symbol] conflict type as symbol
      #
      # @api private
      def self.conflict_code_to_type(code)
        conflict_types = {
          '1' => :both_added,
          '2' => :both_modified,
          '3' => :added_by_us,
          '4' => :deleted_by_them,
          '5' => :added_by_them,
          '6' => :deleted_by_us,
          '7' => :both_deleted,
          '8' => :renamed_by_us,
          '9' => :renamed_by_them
        }

        conflict_types[code] || :unknown_conflict
      end

      # Extract stage information from tokens
      #
      # @param tokens [Array<String>] split line tokens
      # @param start_index [Integer] index of the mode token
      # @return [Hash, nil] stage information or nil if not present
      #
      # @api private
      def self.extract_stage_info(tokens, start_index)
        mode = tokens[start_index]
        object_id = tokens[start_index + 1]

        if mode == '0' && object_id == '0000000000000000000000000000000000000000'
          nil
        else
          { mode: mode, object_id: object_id }
        end
      end

      # Initialize a new unmerged entry
      #
      # @param path [String] file path
      # @param conflict_type [Symbol] type of merge conflict
      # @param stage_1 [Hash, nil] stage 1 (common ancestor) information
      # @param stage_2 [Hash, nil] stage 2 (ours) information
      # @param stage_3 [Hash, nil] stage 3 (theirs) information
      #
      # @api private
      def initialize(path, conflict_type, stage_1, stage_2, stage_3)
        super(path)
        @conflict_type = conflict_type
        @stage_1 = stage_1
        @stage_2 = stage_2
        @stage_3 = stage_3
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for unmerged entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always true for unmerged entries
      #
      # @api private
      def unstaged?
        true
      end

      # Get the worktree status
      #
      # @return [Symbol] always :updated_but_unmerged for unmerged entries
      #
      # @api private
      def worktree_status
        :updated_but_unmerged
      end
    end
  end
end # frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an unmerged file in git status
    #
    # @api private
    class UnmergedEntry < Entry
      # @attribute [r] stage_one
      #
      # Stage 1 (common ancestor) mode and object ID
      #
      # @example
      #   entry.stage_one #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 1 information or nil if not present
      #
      # @api private
      attr_reader :stage_one

      # @attribute [r] stage_two
      #
      # Stage 2 (ours) mode and object ID
      #
      # @example
      #   entry.stage_two #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 2 information or nil if not present
      #
      # @api private
      attr_reader :stage_two

      # @attribute [r] stage_three
      #
      # Stage 3 (theirs) mode and object ID
      #
      # @example
      #   entry.stage_three #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 3 information or nil if not present
      #
      # @api private
      attr_reader :stage_three

      # @attribute [r] conflict_type
      #
      # Type of merge conflict
      #
      # @example
      #   entry.conflict_type #=> :both_added
      #
      # @return [Symbol] conflict type
      #
      # @api private
      attr_reader :conflict_type

      # Parse a git status line to create an unmerged entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UnmergedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split(' ')

        # Extract conflict type from the status code (XY)
        status_code = tokens[1]
        conflict_type = status_code_to_conflict_type(status_code)

        # Extract stage information (skip the submodule field at index 2)
        # Format: u <XY> <sub> <m1> <m2> <m3> <mW> <h1> <h2> <h3> <path>
        stage_1 = extract_stage_info(tokens, 3, 7) # mode at index 3, hash at index 7
        stage_2 = extract_stage_info(tokens, 4, 8) # mode at index 4, hash at index 8
        stage_3 = extract_stage_info(tokens, 5, 9) # mode at index 5, hash at index 9

        # Get the path
        path = tokens[10]

        new(path, conflict_type, stage_1, stage_2, stage_3)
      end

      # Convert status code to a conflict type symbol
      #
      # @param status_code [String] two-character status code (XY)
      # @return [Symbol] conflict type as symbol
      #
      # @api private
      def self.status_code_to_conflict_type(status_code)
        case status_code
        when 'DD' then :both_deleted
        when 'AU' then :added_by_us
        when 'UD' then :deleted_by_them
        when 'UA' then :added_by_them
        when 'DU' then :deleted_by_us
        when 'AA' then :both_added
        when 'UU' then :both_modified
        else :unknown_conflict
        end
      end

      # Extract stage information from tokens
      #
      # @param tokens [Array<String>] split line tokens
      # @param mode_index [Integer] index of the mode token
      # @param hash_index [Integer] index of the hash token
      # @return [Hash, nil] stage information or nil if not present
      #
      # @api private
      def self.extract_stage_info(tokens, mode_index, hash_index)
        mode = tokens[mode_index]
        object_id = tokens[hash_index]

        if mode == '0' && object_id == '0000000000000000000000000000000000000000'
          nil
        else
          { mode: mode, object_id: object_id }
        end
      end

      # Initialize a new unmerged entry
      #
      # @param path [String] file path
      # @param conflict_type [Symbol] type of merge conflict
      # @param stage_one [Hash, nil] stage 1 (common ancestor) information
      # @param stage_two [Hash, nil] stage 2 (ours) information
      # @param stage_three [Hash, nil] stage 3 (theirs) information
      #
      # @api private
      def initialize(path, conflict_type, stage_one, stage_two, stage_three)
        super(path)
        @conflict_type = conflict_type
        @stage_one = stage_one
        @stage_two = stage_two
        @stage_three = stage_three
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for unmerged entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always true for unmerged entries
      #
      # @api private
      def unstaged?
        true
      end

      # Get the worktree status
      #
      # @return [Symbol] always :updated_but_unmerged for unmerged entries
      #
      # @api private
      def worktree_status
        :updated_but_unmerged
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_one
      #
      # @api private
      def stage_1
        @stage_one
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_two
      #
      # @api private
      def stage_2
        @stage_two
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_three
      #
      # @api private
      def stage_3
        @stage_three
      end
    end
  end
end # frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an unmerged file in git status
    #
    # @api private
    class UnmergedEntry < Entry
      # @attribute [r] stage_one
      #
      # Stage 1 (common ancestor) mode and object ID
      #
      # @example
      #   entry.stage_one #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 1 information or nil if not present
      #
      # @api private
      attr_reader :stage_one

      # @attribute [r] stage_two
      #
      # Stage 2 (ours) mode and object ID
      #
      # @example
      #   entry.stage_two #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 2 information or nil if not present
      #
      # @api private
      attr_reader :stage_two

      # @attribute [r] stage_three
      #
      # Stage 3 (theirs) mode and object ID
      #
      # @example
      #   entry.stage_three #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 3 information or nil if not present
      #
      # @api private
      attr_reader :stage_three

      # @attribute [r] conflict_type
      #
      # Type of merge conflict
      #
      # @example
      #   entry.conflict_type #=> :both_added
      #
      # @return [Symbol] conflict type
      #
      # @api private
      attr_reader :conflict_type

      # Parse a git status line to create an unmerged entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UnmergedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split(' ')

        # Extract conflict type (1st character after 'u')
        conflict_code = tokens[1][0]
        conflict_type = conflict_code_to_type(conflict_code)

        # Extract stage information
        stage_one = extract_stage_info(tokens, 2) # 2, 3
        stage_two = extract_stage_info(tokens, 4) # 4, 5
        stage_three = extract_stage_info(tokens, 6) # 6, 7

        # Get the path
        path = tokens[8]

        new(path, conflict_type, stage_one, stage_two, stage_three)
      end

      # Convert conflict code to a symbol
      #
      # @param code [String] conflict code
      # @return [Symbol] conflict type as symbol
      #
      # @api private
      def self.conflict_code_to_type(code)
        conflict_types = {
          '1' => :both_added,
          '2' => :both_modified,
          '3' => :added_by_us,
          '4' => :deleted_by_them,
          '5' => :added_by_them,
          '6' => :deleted_by_us,
          '7' => :both_deleted,
          '8' => :renamed_by_us,
          '9' => :renamed_by_them
        }

        conflict_types[code] || :unknown_conflict
      end

      # Extract stage information from tokens
      #
      # @param tokens [Array<String>] split line tokens
      # @param start_index [Integer] index of the mode token
      # @return [Hash, nil] stage information or nil if not present
      #
      # @api private
      def self.extract_stage_info(tokens, start_index)
        mode = tokens[start_index]
        object_id = tokens[start_index + 1]

        if mode == '0' && object_id == '0000000000000000000000000000000000000000'
          nil
        else
          { mode: mode, object_id: object_id }
        end
      end

      # Initialize a new unmerged entry
      #
      # @param path [String] file path
      # @param conflict_type [Symbol] type of merge conflict
      # @param stage_one [Hash, nil] stage 1 (common ancestor) information
      # @param stage_two [Hash, nil] stage 2 (ours) information
      # @param stage_three [Hash, nil] stage 3 (theirs) information
      #
      # @api private
      def initialize(path, conflict_type, stage_one, stage_two, stage_three)
        super(path)
        @conflict_type = conflict_type
        @stage_one = stage_one
        @stage_two = stage_two
        @stage_three = stage_three
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for unmerged entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always true for unmerged entries
      #
      # @api private
      def unstaged?
        true
      end

      # Get the worktree status
      #
      # @return [Symbol] always :updated_but_unmerged for unmerged entries
      #
      # @api private
      def worktree_status
        :updated_but_unmerged
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_one
      #
      # @api private
      def stage_1
        @stage_one
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_two
      #
      # @api private
      def stage_2
        @stage_two
      end

      # Compatibility method for old API
      #
      # @return [Hash, nil] same as stage_three
      #
      # @api private
      def stage_3
        @stage_three
      end
    end
  end
end # frozen_string_literal: true

require_relative 'entry'

module RubyGit
  module Status
    # Represents an unmerged file in git status
    #
    # @api private
    class UnmergedEntry < Entry
      # @attribute [r] stage_1
      #
      # Stage 1 (common ancestor) mode and object ID
      #
      # @example
      #   entry.stage_1 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 1 information or nil if not present
      #
      # @api private
      attr_reader :stage_1

      # @attribute [r] stage_2
      #
      # Stage 2 (ours) mode and object ID
      #
      # @example
      #   entry.stage_2 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 2 information or nil if not present
      #
      # @api private
      attr_reader :stage_2

      # @attribute [r] stage_3
      #
      # Stage 3 (theirs) mode and object ID
      #
      # @example
      #   entry.stage_3 #=> { mode: '100644', object_id: 'abcdef1234567890' }
      #
      # @return [Hash, nil] stage 3 information or nil if not present
      #
      # @api private
      attr_reader :stage_3

      # @attribute [r] conflict_type
      #
      # Type of merge conflict
      #
      # @example
      #   entry.conflict_type #=> :both_added
      #
      # @return [Symbol] conflict type
      #
      # @api private
      attr_reader :conflict_type

      # Parse a git status line to create an unmerged entry
      #
      # @param line [String] line from git status
      # @return [RubyGit::Status::UnmergedEntry] parsed entry
      #
      # @api private
      def self.parse(line)
        tokens = line.split(' ')

        # Extract conflict type (1st character after 'u')
        conflict_code = tokens[1][0]
        conflict_type = conflict_code_to_type(conflict_code)

        # Extract stage information
        stage_1 = extract_stage_info(tokens, 2) # 2, 3
        stage_2 = extract_stage_info(tokens, 4) # 4, 5
        stage_3 = extract_stage_info(tokens, 6) # 6, 7

        # Get the path
        path = tokens[8]

        new(path, conflict_type, stage_1, stage_2, stage_3)
      end

      # Convert conflict code to a symbol
      #
      # @param code [String] conflict code
      # @return [Symbol] conflict type as symbol
      #
      # @api private
      def self.conflict_code_to_type(code)
        {
          '1' => :both_added,
          '2' => :both_modified,
          '3' => :added_by_us,
          '4' => :deleted_by_them,
          '5' => :added_by_them,
          '6' => :deleted_by_us,
          '7' => :both_deleted,
          '8' => :renamed_by_us,
          '9' => :renamed_by_them
        }[code] || :unknown_conflict
      end

      # Extract stage information from tokens
      #
      # @param tokens [Array<String>] split line tokens
      # @param start_index [Integer] index of the mode token
      # @return [Hash, nil] stage information or nil if not present
      #
      # @api private
      def self.extract_stage_info(tokens, start_index)
        mode = tokens[start_index]
        object_id = tokens[start_index + 1]

        if mode == '0' && object_id == '0000000000000000000000000000000000000000'
          nil
        else
          { mode: mode, object_id: object_id }
        end
      end

      # Initialize a new unmerged entry
      #
      # @param path [String] file path
      # @param conflict_type [Symbol] type of merge conflict
      # @param stage_1 [Hash, nil] stage 1 (common ancestor) information
      # @param stage_2 [Hash, nil] stage 2 (ours) information
      # @param stage_3 [Hash, nil] stage 3 (theirs) information
      #
      # @api private
      def initialize(path, conflict_type, stage_1, stage_2, stage_3)
        super(path)
        @conflict_type = conflict_type
        @stage_1 = stage_1
        @stage_2 = stage_2
        @stage_3 = stage_3
      end

      # Check if the entry has changes in the staging area
      #
      # @return [Boolean] always false for unmerged entries
      #
      # @api private
      def staged?
        false
      end

      # Check if the entry has changes in the working tree
      #
      # @return [Boolean] always true for unmerged entries
      #
      # @api private
      def unstaged?
        true
      end

      # Get the worktree status
      #
      # @return [Symbol] always :updated_but_unmerged for unmerged entries
      #
      # @api private
      def worktree_status
        :updated_but_unmerged
      end
    end
  end
end
