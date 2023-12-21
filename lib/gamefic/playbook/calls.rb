# frozen_string_literal: true

module Gamefic
  class Playbook
    # A collection of responses and syntaxes that constitute the actions
    # available to actors.
    #
    class Calls
      def initialize
        @verb_response_map = Hash.new { |hash, key| hash[key] = [] }
        @synonym_syntax_map = Hash.new { |hash, key| hash[key] = [] }
      end

      def freeze
        super
        @verb_response_map.freeze
        @verb_response_map.values.map(&:freeze)
        @synonym_syntax_map.freeze
        @synonym_syntax_map.values.map(&:freeze)
        self
      end

      def syntaxes
        synonym_syntax_map.values.flatten
      end

      def synonyms
        synonym_syntax_map.keys.compact.sort
      end

      def responses
        verb_response_map.values.flatten
      end

      def verbs
        verb_response_map.keys.compact.sort
      end

      def responses_for *verbs
        verbs.flat_map { |verb| verb_response_map.fetch(verb, []) }
      end

      def syntaxes_for *synonyms
        synonyms.flat_map { |syn| synonym_syntax_map.fetch(syn, []) }
      end

      def add_response response
        verb_response_map[response.verb].unshift response
        sort_responses verb_response_map[response.verb]
        add_syntax response.syntax unless response.verb.to_s.start_with?('_')
        response
      end

      # @param syntax [Syntax]
      # @return [Syntax]
      def add_syntax syntax
        raise "No responses exist for \"#{syntax.verb}\"" unless verb_response_map.key?(syntax.verb)

        return if synonym_syntax_map[syntax.synonym].include?(syntax)

        synonym_syntax_map[syntax.synonym].unshift syntax
        sort_syntaxes synonym_syntax_map[syntax.synonym]
        syntax
      end

      def sort_syntaxes syntaxes
        syntaxes.sort! { |a, b| a.compare b }
      end

      private

      attr_reader :verb_response_map

      attr_reader :synonym_syntax_map

      # @param responses [Array<Response>]
      def sort_responses responses
        responses.sort_by!.with_index { |a, i| [a.precision, -i] }.reverse!
      end
    end
  end
end
