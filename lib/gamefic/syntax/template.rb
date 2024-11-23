# frozen_string_literal: true

module Gamefic
  class Syntax
    # Template data for syntaxes.
    #
    class Template
      PARAM_REGEXP = /^:[a-z0-9_]+$/i.freeze

      # @return [String]
      attr_reader :text

      # @return [Array<String>]
      attr_reader :params

      def initialize text
        @text = text.normalize
        @params = @text.keywords.select { |word| word.start_with?(':') }
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

      # @param tmpl_or_str [Template, String]
      # @return [Template]
      def self.to_template tmpl_or_str
        return tmpl_or_str if tmpl_or_str.is_a?(Template)

        Template.new(tmpl_or_str)
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
