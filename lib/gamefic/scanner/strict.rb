# frozen_string_literal: true

module Gamefic
  module Scanner
    # Strict token matching.
    #
    # An entity will only match a word in a strict scan if the entire word
    # matches one of the entity's keywords.
    #
    class Strict < Base
      NOISE = %w[
        a an the of some
      ].freeze

      # @return [Result]
      def scan
        words = token.keywords
        available = selection.clone
        filtered = []
        words.each_with_index do |word, idx|
          tested = match_word(available, word)
          return matched_result(reduce_noise(filtered, words[0, idx]), words[idx..].join(' ')) if tested.empty?

          filtered = tested
          available = filtered
        end
        matched_result(reduce_noise(filtered, words), '')
      end

      def match_word available, word
        available.select { |obj| (obj.keywords + obj.nuance.keywords).include?(word) }
      end

      def reduce_noise entities, keywords
        noiseless = keywords - NOISE
        entities.reject { |entity| (noiseless - entity.nuance.keywords).empty? }
      end
    end
  end
end
