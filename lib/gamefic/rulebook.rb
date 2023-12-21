# frozen_string_literal: true

require 'gamefic/rulebook/calls'
require 'gamefic/rulebook/events'
require 'gamefic/rulebook/hooks'
require 'gamefic/rulebook/scenes'

module Gamefic
  class Rulebook
    def initialize(stage)
      @stage = stage
      @calls = Calls.new(stage)
      @events = Events.new(stage)
      @hooks = Hooks.new(stage)
      @scenes = Scenes.new(stage)
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
      @calls.freeze
      @events.freeze
      @hooks.freeze
      @scenes.freeze
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

    # An array of all the verbs available in the rulebook. This list only
    # includes verbs that are explicitly defined in reponses. It excludes
    # synonyms that might be defined in syntaxes (see #synonyms).
    #
    # @example
    #   rulebook.respond :verb { |_| nil }
    #   rulebook.interpret 'synonym', 'verb'
    #   rulebook.verbs #=> [:verb]
    #
    # @return [Array<Symbol>]
    def verbs
      @calls.verbs
    end

    # An array of all the verbs defined in responses and any synonyms defined
    # in syntaxes.
    #
    # @example
    #   rulebook.respond :verb { |_| nil }
    #   rulebook.interpret 'synonym', 'verb'
    #   rulebook.synonyms #=> [:synonym, :verb]
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
      hooks.each do |hook|
        break if action.cancelled?

        next unless hook.verb.nil? || hook.verb == action.verb

        @stage.call action, &hook.block
      end
    end
  end
end
