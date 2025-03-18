# frozen_string_literal: true

require 'delegate'
require 'process_executer'

module RubyGit
  module CommandLine
    # Defines the options for RubyGit::CommandLine::Runner
    #
    # @api public
    #
    class Options < ProcessExecuter::Options::RunOptions
      # Alias for brevity
      OptionDefinition = ProcessExecuter::Options::OptionDefinition

      private

      # :nocov: SimpleCov on JRuby reports the last with the last argument line is not covered

      # The options allowed for objects of this class
      # @return [Array<OptionDefinition>]
      # @api private
      def define_options
        [
          *super,
          OptionDefinition.new(:normalize_encoding, default: false, validator: method(:validate_normalize_encoding)),
          OptionDefinition.new(:chomp, default: false, validator: method(:validate_chomp)),
          OptionDefinition.new(:raise_git_errors, default: true, validator: method(:validate_raise_git_errors))
        ].freeze
      end
      # :nocov:

      # Validate the raise_git_errors option value
      # @return [String, nil] the error message if the value is not valid
      # @api private
      def validate_raise_git_errors
        return if [true, false].include?(raise_git_errors)

        errors << "raise_git_errors must be true or false but was #{raise_git_errors.inspect}"
      end

      # Validate the normalize_encoding option value
      # @return [String, nil] the error message if the value is not valid
      # @api private
      def validate_normalize_encoding
        return if [true, false].include?(normalize_encoding)

        errors << "normalize_encoding must be true or false but was #{normalize_encoding.inspect}"
      end

      # Validate the chomp option value
      # @return [String, nil] the error message if the value is not valid
      # @api private
      def validate_chomp
        return if [true, false].include?(chomp)

        errors << "chomp must be true or false but was #{chomp.inspect}"
      end
    end
  end
end
