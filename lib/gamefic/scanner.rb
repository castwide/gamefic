module Gamefic
  # A module for matching objects to tokens.
  #
  module Scanner
    # The result of an attempt to scan objects against a token in a Scanner. It
    # provides an array of matching objects, the text that matched them, and the
    # text that remains unmatched.
    #
    class Result
      # The scanned token
      #
      # @return [String]
      attr_reader :token

      # The scanned objects
      #
      # @return [Array<Object>]
      attr_reader :scanned

      # The matched objects
      #
      # @return [Array<Object>]
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
    end

    # Scan objects against a token. Objects must respond to #split_words with
    # an array of strings. (Gamefic adds a #split_words method to String.)
    #
    # @param objects [Array<#split_words>]
    # @param token [String]
    # @param continued [Boolean]
    # @return [Matches]
    def self.scan objects, token, continued: false
      words = token.split_words
      available = objects.clone
      filtered = []
      words.each_with_index do |word, idx|
        tested = select_strict(available, word)
        tested = select_fuzzy(available, word) if tested.empty?
        return Result.new(objects, token, filtered, words[idx..-1].join(' ')) if tested.empty?

        filtered = tested
        available = filtered
      end
      Result.new(objects, token, filtered, '')
    end

    class << self
      private

      def select_strict available, word
        available.select { |o| o.split_words.include?(word) }
      end

      def select_fuzzy available, word
        available.select { |o| o.split_words.any? { |w| w.start_with?(word) } }
      end
    end
  end
end
