# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  class Plot < Narrative
    def ready
      super
      subplots.each(&:ready)
      players.each(&:start_take)
      players.select(&:concluding?).each { |plyr| rulebook.run_player_conclude_blocks plyr }
      subplots.delete_if(&:concluding?)
    end

    def update
      players.each(&:finish_take)
      super
      subplots.each(&:update)
    end

    # Remove an actor from the game.
    #
    # Calling `uncast` on the plot will also remove the actor from its
    # subplots.
    #
    # @param actor [Actor]
    # @return [Actor]
    def uncast actor
      subplots.each { |sp| sp.uncast actor }
      super
    end

    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      @subplots ||= []
    end

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>] Players to introduce
    # @param config [Hash] Subplot configuration
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: [], **config
      subplot_class.new(self, introduce: introduce, **config)
                   .tap { |sub| subplots.push sub }
    end

    def save
      Snapshot.save self
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
      super(cache.shift)
      subplots.each { |subplot| subplot.attach cache.shift }
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
