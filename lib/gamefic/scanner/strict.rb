# frozen_string_literal: true

module Gamefic
  module Scanner
    # Strict token matching.
    #
    # An entity will only match a word in a strict scan if the entire word
    # matches one of the entity's keywords.
    #
    class Strict < Base
      # @return [Result]
      def scan
        words = token.keywords
        available = selection.clone
        filtered = []
        words.each_with_index do |word, idx|
          tested = match_word(available, word)
          return Result.new(selection, token, filtered, words[idx..].join(' '), self.class) if tested.empty?

          filtered = tested
          available = filtered
        end
        Result.new(selection, token, filtered, '', self.class)
      end

      def match_word available, word
        available.select { |obj| obj.keywords.include?(word) }
      end
    end
  end
end
