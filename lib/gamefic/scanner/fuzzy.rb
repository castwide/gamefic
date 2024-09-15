# frozen_string_literal: true

module Gamefic
  module Scanner
    class Fuzzy < Strict
      def match_word available, word
        available.select { |obj| obj.keywords.any? { |wrd| wrd.start_with?(word) } }
      end
    end
  end
end
