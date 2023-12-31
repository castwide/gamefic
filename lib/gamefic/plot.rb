# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  class Plot < Narrative
    include Delegatable::Plots

    def initialize
      @subplots = []
      super
    end

    def ready
      super
      subplots.each(&:ready)
      players.each(&:start_take)
      subplots.delete_if(&:concluding?)
      players.select(&:concluding?).each { |plyr| rulebook.run_player_conclude_blocks plyr }
    end

    def update
      players.each(&:finish_take)
      super
      subplots.each(&:update)
    end

    # Remove an actor from the game.
    #
    # Calling `exeunt` on the plot will also remove the actor from its
    # subplots.
    #
    # @todo This is a first implementation, subject to change.
    #
    # @param actor [Actor]
    # @return [Actor]
    def exeunt actor
      subplots.each { |sp| sp.exeunt actor }
      super
    end

    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      @subplots ||= []
    end

    def inspect
      "#<#{self.class}>"
    end

    def detach
      cache = [@rulebook]
      @rulebook = nil
      cache.concat subplots.map(&:detach)
      cache
    end

    def attach(cache)
      super(cache.unshift)
      subplots.each { |subplot| subplot.attach cache.unshift }
    end

    def hydrate
      super
      subplots.each(&:hydrate)
    end

    def self.restore data
      Snapshot.restore data
    end
  end
end
