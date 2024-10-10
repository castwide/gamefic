# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  class Plot < Narrative
    def seed
      super
      chapters.each(&:seed)
    end

    def script
      super
      chapters.each(&:script)
      rulebook.scenes.with_defaults self
    end

    def post_script
      super
      chapters.freeze
    end

    def chapters
      @chapters ||= self.class.appended_chapters.map { |klass| klass.new(self) }
    end

    def ready
      super
      subplots.each(&:ready)
      players.each(&:start)
      subplots.each(&:conclude) if concluding?
      players.select(&:concluding?).each { |plyr| rulebook.run_player_conclude_blocks plyr }
      subplots.delete_if(&:concluding?)
    end

    def update
      players.each(&:finish)
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

    def self.append chapter
      appended_chapters.add chapter
    end

    def self.appended_chapters
      @appended_chapters ||= Set.new
    end

    def self.restore data
      Snapshot.restore data
    end
  end
end
