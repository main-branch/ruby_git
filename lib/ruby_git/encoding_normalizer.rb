# frozen_string_literal: true

require 'rchardet'

module RubyGit
  # Utility to normalize string encoding
  # @api public
  module EncodingNormalizer
    # Detects the character encoding used to create a string or binary data
    #
    # Detects the encoding of a string or return binary if it cannot be detected
    #
    # @example
    #   RubyGit::EncodingNormalizer.detect_encoding("Hello, world!") #=> "ascii"
    #   RubyGit::EncodingNormalizer.detect_encoding("\xCB\xEF\xF1\xE5\xEC") #=> "ISO-8859-7"
    #   RubyGit::EncodingNormalizer.detect_encoding("\xC0\xCC\xB0\xCD\xC0\xBA") #=> "EUC-KR"
    #
    # @param str [String] the string to detect the encoding of
    # @return [String] the detected encoding
    #
    def self.detect_encoding(str)
      CharDet.detect(str)&.dig('encoding') || Encoding::BINARY.name
    end

    # Normalizes the encoding to normalize_to
    #
    # @example
    #   RubyGit::EncodingNormalizer.normalize("Hello, world!") #=> "Hello, world!"
    #   RubyGit::EncodingNormalizer.normalize("\xCB\xEF\xF1\xE5\xEC") #=> "Λορεμ"
    #   RubyGit::EncodingNormalizer.normalize("\xC0\xCC\xB0\xCD\xC0\xBA") #=> "이것은"
    #
    # @param str [String] the string to normalize
    # @param normalize_to [String] the name of the encoding to normalize to
    #
    # @return [String] the string with encoding converted to normalize_to
    #
    # @raise [Encoding::UndefinedConversionError] if the string cannot be converted to the default encoding
    #
    def self.normalize(str, normalize_to: Encoding::UTF_8.name)
      encoding_options = { invalid: :replace, undef: :replace }

      detected_encoding = detect_encoding(str)

      return str if str.valid_encoding? && detected_encoding == normalize_to

      str.encode(normalize_to, detected_encoding, **encoding_options)
    end
  end
end
