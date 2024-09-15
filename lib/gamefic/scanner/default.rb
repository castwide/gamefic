# frozen_string_literal: true

module Gamefic
  module Scanner
    class Default
      # @return [Array<Entity>, String, Regexp]
      attr_reader :selection

      # @return [String]
      attr_reader :token

      # @param selection [Array<Entity>, String, Regexp]
      # @param token [String]
      def initialize selection, token
        @selection = selection
        @token = token
      end

      # @return [Result]
      def scan
        words = token.keywords
        available = selection.clone
        filtered = []
        words.each_with_index do |word, idx|
          tested = match_word(available, word)
          return Result.new(selection, token, filtered, words[idx..].join(' ')) if tested.empty?

          filtered = tested
          available = filtered
        end
        Result.new(selection, token, filtered, '')
      end

      def match_word available, word
        available.select { |obj| obj.keywords.include?(word) }
      end
    end
  end
end
