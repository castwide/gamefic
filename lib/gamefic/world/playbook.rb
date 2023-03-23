# frozen_string_literal: true

module Gamefic
  module World
    # A container for the rules that compose and process actions. Playbooks
    # consist of three types of components:
    #   * Responses
    #   * Syntaxes
    #   * Before and After Hooks
    #
    class Playbook
      # @return [Array<Action::Hook>]
      attr_reader :before_actions

      # @return [Array<Action::Hook>]
      attr_reader :after_actions

      def initialize
        @before_actions = []
        @after_actions = []
        @verb_response_map = Hash.new { |hash, key| hash[key] = [] }
        @synonym_syntax_map = Hash.new { |hash, key| hash[key] = [] }
      end

      def freeze
        super
        @before_actions.freeze
        @after_actions.freeze
        @verb_response_map.freeze
        @synonym_syntax_map.freeze
      end

      # Add a response to the playbook.
      #
      # @param verb [Symbol]
      # @param queries [Array<Query::Base>]
      # @param block [Proc]
      # @return [Response]
      def respond verb, *queries, &block
        add_response Response.new(verb, *queries, &block)
      end

      # Add a meta response to the playbook.
      #
      # @param verb [Symbol]
      # @param queries [Array<Query::Base>]
      # @param block [Proc]
      # @return [Response]
      def meta verb, *queries, &block
        add_response Response.new(verb, *queries, meta: true, &block)
      end

      # Add a syntax to the playbook.
      #
      # @param template [String]
      # @param command [String]
      # @return [Syntax]
      def interpret template, command
        add_syntax Syntax.new(template, command)
      end

      # Add a proc to be executed before an action. The block receives the
      # the current action as an argument. Calling `cancel` on the action will
      # stop execution of the action and any subsequent hooks.
      #
      # The optional `verb` argument prevents the block from running unless the
      # action's verb matches it.
      #
      # @param verb [Symbol, nil]
      # @param block [Proc]
      # @yieldparam [Action]
      # @return [Action::Hook]
      def before_action verb = nil, &block
        before_actions.push(Action::Hook.new(verb, block))
                      .last
      end

      # Add a proc to be executed before an action. The block receives the
      # the current action as an argument. Calling `cancel` on the action will
      # stop execution of any subsequent hooks.
      #
      # The optional `verb` argument prevents the block from running unless the
      # action's verb matches it.
      #
      # @param verb [Symbol, nil]
      # @param block [Proc]
      # @yieldparam [Action]
      # @return [Action::Hook]
      def after_action verb = nil, &block
        after_actions.push(Action::Hook.new(verb, block))
                    .last
      end

      # @return [Array<Response>]
      def responses
        verb_response_map.values.flatten
      end

      # @return [Array<Syntax>]
      def syntaxes
        synonym_syntax_map.values.flatten
      end

      # An array of all the verbs available in the playbook. This list only
      # includes verbs that are explicitly defined in reponses. It excludes
      # synonyms that might be defined in syntaxes (see #synonyms).
      #
      # @example
      #   playbook.respond :verb { |_| nil }
      #   playbook.interpret 'synonym', 'verb'
      #   playbook.verbs #=> [:verb]
      #
      # @return [Array<Symbol>]
      def verbs
        verb_response_map.keys.compact.sort
      end

      # An array of all the verbs defined in responses and any synonyms defined
      # in syntaxes.
      #
      # @example
      #   playbook.respond :verb { |_| nil }
      #   playbook.interpret 'synonym', 'verb'
      #   playbook.synonyms #=> [:synonym, :verb]
      #
      def synonyms
        synonym_syntax_map.keys.compact.sort
      end

      # @param verbs [Array<Symbol>]
      # @return [Array<Response>]
      def responses_for *verbs
        verbs.flat_map { |verb| verb_response_map.fetch(verb, []) }
      end

      # @param words [Array<Symbol>]
      # @return [Array<Syntax>]
      def syntaxes_for *synonyms
        synonyms.flat_map { |syn| synonym_syntax_map.fetch(syn, []) }
      end

      private

      attr_reader :synonym_syntax_map

      attr_reader :verb_response_map

      def add_response response
        verb_response_map[response.verb].unshift response
        sort_responses verb_response_map[response.verb]
        add_syntax response.syntax
        response
      end

      def add_syntax syntax
        raise "No responses exist for \"#{syntax.verb}\"" unless verb_response_map.key?(syntax.verb)
        return if synonym_syntax_map[syntax.synonym].include?(syntax)
        synonym_syntax_map[syntax.synonym].unshift syntax
        sort_syntaxes synonym_syntax_map[syntax.synonym]
        syntax
      end

      # @param responses [Array<Response>]
      def sort_responses responses
        responses.sort_by!.with_index { |a, i| [a.precision, -i] }.reverse!
      end

      def sort_syntaxes syntaxes
        syntaxes.sort! do |a, b|
          if a.word_count == b.word_count
            b.synonym <=> a.synonym
          else
            b.word_count <=> a.word_count
          end
        end
      end
    end
  end
end
