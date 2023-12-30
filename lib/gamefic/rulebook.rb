# frozen_string_literal: true

require 'gamefic/rulebook/calls'
require 'gamefic/rulebook/events'
require 'gamefic/rulebook/hooks'
require 'gamefic/rulebook/scenes'

module Gamefic
  class Rulebook
    attr_reader :calls

    attr_reader :events

    attr_reader :hooks

    attr_reader :scenes

    attr_reader :narrative

    attr_reader :stage

    # @param narrative [Narrative]
    def initialize(narrative)
      @narrative = narrative
      @stage = @narrative.method(:instance_exec)
      @calls = Calls.new
      @events = Events.new
      @hooks = Hooks.new
      @scenes = Scenes.new
    end

    def freeze
      super
      @calls.freeze
      @events.freeze
      @hooks.freeze
      @scenes.freeze
      self
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

    def run_ready_blocks
      events.ready_blocks.each { |blk| Stage.run narrative, &blk }
    end

    def run_update_blocks
      events.update_blocks.each { |blk| Stage.run narrative, &blk }
    end

    def run_before_actions action
      run_action_hooks action, hooks.before_actions
    end

    def run_after_actions action
      run_action_hooks action, hooks.after_actions
    end

    def run_conclude_blocks
      events.conclude_blocks.each { |blk| Stage.run narrative, &blk }
    end

    def run_player_conclude_blocks player
      events.player_conclude_blocks.each { |blk| Stage.run(narrative) { blk.call(player) } }
    end

    def run_player_output_blocks player, output
      events.player_output_blocks.each { |blk| Stage.run(narrative) { blk.call(player, output) } }
    end

    def empty?
      calls.empty? && hooks.empty? && scenes.empty? && events.empty?
    end

    private

    def run_action_hooks action, hooks
      hooks.each do |hook|
        break if action.cancelled?

        next unless hook.verb.nil? || hook.verb == action.verb

        Stage.run(narrative) { hook.block.call(action) }
      end
    end
  end
end
