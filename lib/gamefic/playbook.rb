# frozen_string_literal: true

require 'gamefic/playbook/calls'
require 'gamefic/playbook/hooks'

module Gamefic
  # A container for the rules that compose and process actions. Playbooks
  # consist of three types of components:
  #   * Responses
  #   * Syntaxes
  #   * Action Hooks (before and after)
  #
  class Playbook
    def initialize stage
      @stage = stage
      @hooks = Hooks.new
      @calls = Calls.new
    end

    # @return [Array<Action::Hook>]
    def before_actions
      @hooks.before_actions
    end

    # @return [Array<Action::Hook>]
    def after_actions
      @hooks.after_actions
    end

    def freeze
      super
      @hooks.freeze
      @calls.freeze
      self
    end

    def respond_with response
      @calls.add_response response
    end

    def interpret_with syntax
      @calls.add_syntax syntax
    end

    def before_action verb = nil, &hook
      before_actions.push Action::Hook.new(verb, hook)
    end

    def after_action verb = nil, &hook
      after_actions.push Action::Hook.new(verb, hook)
    end

    # @return [Array<Response>]
    def responses
      @calls.responses
    end

    # @return [Array<Syntax>]
    def syntaxes
      @calls.syntaxes
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
      @calls.verbs
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
      @calls.synonyms
    end

    # Get an array of all the responses that match a list of verbs.
    #
    # @param verbs [Array<Symbol>]
    # @return [Array<Response>]
    def responses_for *verbs
      @calls.responses_for *verbs
    end

    # Get an array of all the syntaxes that match a lit of verbs.
    #
    # @param words [Array<Symbol>]
    # @return [Array<Syntax>]
    def syntaxes_for *synonyms
      @calls.syntaxes_for *synonyms
    end

    def run_before_actions action
      run_action_hooks action, before_actions
    end

    def run_after_actions action
      run_action_hooks action, after_actions
    end

    private

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
