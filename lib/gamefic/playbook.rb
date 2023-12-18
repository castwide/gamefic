# frozen_string_literal: true

module Gamefic
  # A container for the rules that compose and process actions. Playbooks
  # consist of three types of components:
  #   * Responses
  #   * Syntaxes
  #   * Action Hooks (before and after)
  #
  class Playbook
    # @return [Array<Action::Hook>]
    attr_reader :before_actions

    # @return [Array<Action::Hook>]
    attr_reader :after_actions

    def initialize stage
      @stage = stage
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
      @verb_response_map.values.map(&:freeze)
      @synonym_syntax_map.freeze
      @synonym_syntax_map.values.map(&:freeze)
      self
    end

    def respond_with response
      add_response response
    end

    def interpret_with syntax
      add_syntax syntax
    end

    def before_action verb = nil, &hook
      before_actions.push Action::Hook.new(verb, hook)
    end

    def after_action verb = nil, &hook
      after_actions.push Action::Hook.new(verb, hook)
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

    # Get an array of all the responses that match a list of verbs.
    #
    # @param verbs [Array<Symbol>]
    # @return [Array<Response>]
    def responses_for *verbs
      verbs.flat_map { |verb| verb_response_map.fetch(verb, []) }
    end

    # Get an array of all the syntaxes that match a lit of verbs.
    #
    # @param words [Array<Symbol>]
    # @return [Array<Syntax>]
    def syntaxes_for *synonyms
      synonyms.flat_map { |syn| synonym_syntax_map.fetch(syn, []) }
    end

    def run_before_actions action
      run_action_hooks action, before_actions
    end

    def run_after_actions action
      run_action_hooks action, after_actions
    end

    private

    # @return [Hash]
    attr_reader :synonym_syntax_map

    # @return [Hash]
    attr_reader :verb_response_map

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

    # @param responses [Array<Response>]
    def sort_responses responses
      responses.sort_by!.with_index { |a, i| [a.precision, -i] }.reverse!
    end

    def sort_syntaxes syntaxes
      syntaxes.sort! { |a, b| a.compare b }
    end

    def run_action_hooks action, hooks
      return if action.cancelled?

      hooks.each do |hook|
        next unless hook.verb.nil? || hook.verb == action.verb

        @stage.call action, &hook.block

        break if action.cancelled?
      end
    end
  end
end
