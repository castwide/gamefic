# frozen_string_literal: true

module Gamefic
  module Scanner
    # Fuzzy token matching.
    #
    # An entity will match a word in a fuzzy scan if it matches the beginning
    # of one of the entity's keywords, e.g., `pen` is a fuzzy token match for
    # the keyword `pencil`.
    #
    class Fuzzy < Strict
      def match_word available, word
        available.select { |obj| obj.keywords.any? { |wrd| wrd.start_with?(word) } }
      end
    end
  end
end
