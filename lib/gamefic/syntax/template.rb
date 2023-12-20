# frozen_string_literal: true

module Gamefic
  class Syntax
    # Template data for syntaxes.
    #
    class Template
      # @return [String]
      attr_reader :text

      # @return [Array<String>]
      attr_reader :params

      def initialize text
        @text = text.normalize
        @params = @text.keywords.select { |word| word.start_with?(':') }
      end

      # @return [self]
      def to_template
        self
      end

      def keywords
        text.keywords
      end

      def to_s
        text
      end

      def regexp
        @regexp ||= Regexp.new("^#{make_tokens.join(' ')}$", Regexp::IGNORECASE)
      end

      def verb
        @verb ||= Syntax.literal_or_nil(keywords.first)
      end

      def compare other
        if keywords.length == other.keywords.length
          other.verb <=> verb
        else
          other.keywords.length <=> keywords.length
        end
      end

      private

      # @return [Array<String>]
      def make_tokens
        keywords.map.with_index do |word, idx|
          next word unless word.match?(PARAM_REGEXP)

          next nil if idx.positive? && keywords[idx - 1].match?(PARAM_REGEXP)

          '([\w\W\s\S]*?)'
        end.compact
      end
    end
  end
end
