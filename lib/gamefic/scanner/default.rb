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
        scan_strict
      end

      def strict
        scan_strict
      end

      def fuzzy
        scan_fuzzy
      end

      private

      def scan_strict_or_fuzzy method
        words = token.keywords
        available = selection.clone
        filtered = []
        words.each_with_index do |word, idx|
          tested = send(method, available, word)
          return Result.new(selection, token, filtered, words[idx..].join(' ')) if tested.empty?

          filtered = tested
          available = filtered
        end
        Result.new(selection, token, filtered, '')
      end

      # @return [Result]
      def scan_strict
        scan_strict_or_fuzzy(:select_strict)
      end

      # @return [Result]
      def scan_fuzzy
        scan_strict_or_fuzzy(:select_fuzzy)
      end

      # @return [Result]
      def scan_text
        case selection
        when Regexp
          return Result.new(selection, token, token, '') if token =~ selection
        else
          return Result.new(selection, token, selection, token[selection.length..]) if token.start_with?(selection)
        end
        Result.new(selection, token, '', token)
      end

      def select_strict available, word
        available.select { |obj| obj.keywords.include?(word) }
      end

      def select_fuzzy available, word
        available.select { |obj| obj.keywords.any? { |wrd| wrd.start_with?(word) } }
      end
    end
  end
end
