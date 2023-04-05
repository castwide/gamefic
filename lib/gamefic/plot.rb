# frozen_string_literal: true

module Gamefic
  class Plot
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host,      'gamefic/plot/host'

    include Direction
    extend Scripting::ClassMethods
    include Host
    include Snapshot

    # @return [Hash]
    attr_reader :metadata

    def initialize
      start_production
      # run_scripts
      # default_scene && default_conclusion # Make sure they exist
    end

    # True if at least one player has been introduced.
    #
    def introduced?
      @introduced ||= false
    end

    # True if all players have reached conclusions.
    def concluded?
      introduced? && (players.empty? || players.all?(&:concluded?))
    end

    def ready
      subplots.delete_if(&:concluded?)
      subplots.each(&:ready)
      super
    end

    def update
      subplots.each(&:update)
      super
    end

    # Make a character that a player will control on introduction.
    #
    # @return [Gamefic::Actor]
    def make_player_character
      # @todo Should we even bother with player_class? This could stand to be
      #   more robust, but the adjustable player class seems like a step too
      #   far.
      cast Gamefic::Actor, name: 'yourself', synonyms: 'self myself you me', proper_named: true
    end

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The class of the subplot to be created (Subplot by default)
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil, next_cue: nil, **more
      subplot = subplot_class.new(self, introduce: introduce, next_cue: next_cue, **more)
      subplots.push subplot
      subplot
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end

module Gamefic
  def self.script &block
    Gamefic::Plot.script &block
  end
end
