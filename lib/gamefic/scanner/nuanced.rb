# frozen_string_literal: true

module Gamefic
  module Scanner
    # Nuanced token matching.
    #
    # 
    #
    class Nuanced < Fuzzy
      def scan
        result = super
        return result if result.matched.empty? || result.remainder.empty?

        used = token.keywords - result.remainder.keywords
        concrete = result.matched.select do |object|
          object.keywords.any? { |word| used.any? { |word2| word2.start_with?(word) } }
        end
        matched_result concrete, result.remainder
      end

      def match_word available, word
        available.select { |obj| (obj.keywords + obj.nuance.keywords).any? { |wrd| wrd.start_with?(word) } }
      end
    end
  end
end
