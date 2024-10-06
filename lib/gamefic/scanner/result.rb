# frozen_string_literal: true

module Gamefic
  module Scanner
    # The result of an attempt to scan objects against a token in a Scanner. It
    # provides an array of matching objects, the text that matched them, and the
    # text that remains unmatched.
    #
    class Result
      # The scanned objects
      #
      # @return [Array<Entity>, String, Regexp]
      attr_reader :scanned

      # The scanned token
      #
      # @return [String]
      attr_reader :token

      # The matched objects
      #
      # @return [Array<Entity>, String]
      attr_reader :matched
      alias match matched

      # The remaining (unmatched) portion of the token
      #
      # @return [String]
      attr_reader :remainder

      attr_reader :processor

      def initialize scanned, token, matched, remainder, processor
        @scanned = scanned
        @token = token
        @matched = matched
        @remainder = remainder
        @processor = processor
      end

      def passed
        @passed ||= (token.keywords - remainder.keywords).join(' ')
      end

      def strictness
        @strictness ||= Scanner.strictness(processor)
      end

      def filter *args
        Scanner::Result.new(
          scanned,
          token,
          match.that_are(*args),
          remainder,
          processor
        )
      end

      def self.unmatched scanned, token, processor
        new(scanned, token, [], token, processor)
      end
    end
  end
end
