# frozen_string_literal: true

require 'delegate'
require 'process_executer'

module RubyGit
  module CommandLine
    # Defines the options for RubyGit::CommandLine::Runner
    #
    # @api public
    #
    class Options < ProcessExecuter::Options::RunWithCaptureOptions
      # Alias for brevity
      OptionDefinition = ProcessExecuter::Options::OptionDefinition

      private

      # The options allowed for objects of this class
      # @return [Array<OptionDefinition>]
      # @api private
      def define_options
        [
          *super,
          OptionDefinition.new(:normalize_encoding, default: false, validator: method(:validate_normalize_encoding)),
          OptionDefinition.new(:chomp, default: false, validator: method(:validate_chomp))
        ].freeze
      end

      # Wrap ProcessExecuter::ArgumentError in a RubyGit::ArgumentError
      # @return [void]
      # @raise [RubyGit::ArgumentError] if the options are invalid
      # @api private
      def validate_options
        super
      rescue ProcessExecuter::ArgumentError => e
        raise RubyGit::ArgumentError, e.message, cause: e
      end

      # Validate the normalize_encoding option value
      # @return [String, nil] the error message if the value is not valid
      # @api private
      def validate_normalize_encoding(_key, _value)
        return if [true, false].include?(normalize_encoding)

        errors << "normalize_encoding must be true or false but was #{normalize_encoding.inspect}"
      end

      # Validate the chomp option value
      # @return [String, nil] the error message if the value is not valid
      # @api private
      def validate_chomp(_key, _value)
        return if [true, false].include?(chomp)

        errors << "chomp must be true or false but was #{chomp.inspect}"
      end
    end
  end
end
