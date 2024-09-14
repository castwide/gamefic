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

      # The remaining (unmatched) portion of the token
      #
      # @return [String]
      attr_reader :remainder

      def initialize scanned, token, matched, remainder
        @scanned = scanned
        @token = token
        @matched = matched
        @remainder = remainder
      end

      def self.unmatched scanned, token
        new(scanned, token, [], token)
      end
    end
  end
end
