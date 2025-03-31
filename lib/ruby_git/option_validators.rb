# frozen_string_literal: true

module RubyGit
  # Module containing option validators for RubyGit
  # @api public
  module OptionValidators
    # Raise an error if an option is not a Boolean (or optionally nil) value
    # @param name [String] the name of the option
    # @param value [Object] the value of the option
    # @param nullable [Boolean] whether the option can be nil (default is false)
    # @return [void]
    # @raise [ArgumentError] if the option is not a Boolean (or optionally nil) value
    # @api private
    def validate_boolean_option(name:, value:, nullable: false)
      return if nullable && value.nil?

      return if [true, false].include?(value)

      raise ArgumentError, "The '#{name}:' option must be a Boolean value but was #{value.inspect}"
    end

    # Raise an error if an option is not a String (or optionally nil) value
    # @param name [String] the name of the option
    # @param value [Object] the value of the option
    # @param nullable [Boolean] whether the option can be nil (default is false)
    # @return [void]
    # @raise [ArgumentError] if the option is not a String (or optionally nil) value
    # @api private
    def validate_string_option(name:, value:, nullable: false)
      return if nullable && value.nil?

      return if value.is_a?(String)

      raise ArgumentError, "The '#{name}:' option must be a String or nil but was #{value.inspect}"
    end
  end
end
