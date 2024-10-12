# frozen_string_literal: true

require 'gamefic/rulebook/calls'
require 'gamefic/rulebook/events'
require 'gamefic/rulebook/hooks'
require 'gamefic/rulebook/scenes'

module Gamefic
  # A collection of rules that define the behavior of a narrative.
  #
  # Rulebooks provide a way to separate narrative data from code. This
  # separation is necessary to ensure that the game state can be serialized in
  # snapshots.
  #
  class Rulebook
    # @return [Calls]
    attr_reader :calls

    # @return [Events]
    attr_reader :events

    # @return [Hooks]
    attr_reader :hooks

    # @return [Scenes]
    attr_reader :scenes

    def initialize
      @calls = Calls.new
      @events = Events.new
      @hooks = Hooks.new
      @scenes = Scenes.new
    end

    def freeze
      super
      [@calls, @events, @hooks, @scenes].each(&:freeze)
      self
    end

    # @return [Array<Syntax>]
    # def syntaxes
    #   @calls.syntaxes
    # end

    # An array of all the verbs defined in responses and any synonyms defined
    # in syntaxes.
    #
    # @example
    #   rulebook.respond :verb { |_| nil }
    #   rulebook.interpret 'synonym', 'verb'
    #   rulebook.synonyms #=> [:synonym, :verb]
    #
    # def synonyms
    #   @calls.synonyms
    # end

    # Get an array of all the syntaxes that match a list of verbs.
    #
    # @param words [Array<Symbol>]
    # @return [Array<Syntax>]
    # def syntaxes_for *synonyms
    #   @calls.syntaxes_for *synonyms
    # end

    # def run_ready_blocks
    #   events.ready_blocks.each(&:run)
    # end

    # def run_update_blocks
    #   events.update_blocks.each(&:run)
    # end

    # def run_before_actions action
    #   hooks.run_before action
    # end

    # def run_after_actions action
    #   hooks.run_after action
    # end

    def run_conclude_blocks
      events.conclude_blocks.each(&:run)
    end

    def run_player_conclude_blocks player
      events.player_conclude_blocks.each { |blk| blk.run(player) }
    end

    def run_player_output_blocks player, output
      events.player_output_blocks.each { |blk| blk.run(player, output) }
    end

    def empty?
      calls.empty? && hooks.empty? && scenes.empty? && events.empty?
    end
  end
end
