module Gamefic
  # A module for matching objects to tokens.
  #
  module Scanner
    NEST_REGEXP = / in | on | of | from | inside | from inside /

    # The result of an attempt to scan objects against a token in a Scanner. It
    # provides an array of matching objects, the text that matched them, and the
    # text that remains unmatched.
    #
    class Result
      # The scanned objects
      #
      # @return [Array<Object>]
      attr_reader :scanned

      # The scanned token
      #
      # @return [String]
      attr_reader :token

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

    # Scan entities against a token.
    #
    # @param objects [Array<Gamefic::Entity>]
    # @param token [String]
    # @return [Result]
    def self.scan objects, token
      # @note Theoretically, scanned objects only have to implement two
      #   methods:
      #     *  #keywords => [Array<String>]
      #     *  #children => [Array<#keywords, #children>]
      #   The #children method is optional, but if it's implemented, each
      #   element of the #children array should also implement #children.

      words = token.keywords
      available = objects.clone
      filtered = []
      if nested?(token) && objects.all?(&:children)
        denest(objects, token)
      else
        words.each_with_index do |word, idx|
          tested = select_strict(available, word)
          tested = select_fuzzy(available, word) if tested.empty?
          return Result.new(objects, token, filtered, words[idx..-1].join(' ')) if tested.empty?

          filtered = tested
          available = filtered
        end
        Result.new(objects, token, filtered, '')
      end
    end

    class << self
      private

      def select_strict available, word
        available.select { |o| o.keywords.include?(word) }
      end

      def select_fuzzy available, word
        available.select { |o| o.keywords.any? { |w| w.start_with?(word) } }
      end

      def nested?(token)
        token.match(NEST_REGEXP)
      end

      def denest(objects, token)
        parts = token.split(NEST_REGEXP)
        current = parts.pop
        last_result = scan(objects, current)
        until parts.empty?
          current = "#{parts.last} #{current}"
          result = scan(last_result.matched, current)
          break if result.matched.empty?
          parts.pop
          last_result = result
        end
        return Result.new(objects, token, [], '') if last_result.matched.empty? || last_result.matched.length > 1
        return last_result if parts.empty?
        denest(last_result.matched.first.children, parts.join(' '))
      end
    end
  end
end
