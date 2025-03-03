# frozen_string_literal: true

require 'corelib/marshal' if RUBY_ENGINE == 'opal' # Required in browser

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    include Scripting
    # @!parse extend Gamefic::Scriptable

    select_default_scene Scene::Activity
    select_default_conclusion Scene::Conclusion

    def initialize
      seeds.each { |blk| instance_exec(&blk) }
    end

    # Introduce an actor to the story.
    #
    # @param player [Gamefic::Actor]
    # @return [Gamefic::Actor]
    def introduce(player = Gamefic::Actor.new)
      cast player
      introductions.each { |blk| blk[player] }
      player
    end

    # A narrative is considered to be concluding when all of its players are in
    # a conclusion scene. Engines can use this method to determine whether the
    # game is ready to end.
    #
    def concluding?
      players.empty? || players.all?(&:concluding?)
    end

    # Add an active entity to the narrative.
    #
    # @param active [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast(active)
      active.narratives.add self
      player_set.add active
      entity_set.add active
      active
    end

    # Remove an active entity from the narrative.
    #
    # @param active [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast(active)
      active.narratives.delete self
      player_set.delete active
      entity_set.delete active
      active
    end

    # Complete a game turn.
    #
    # In the base Narrative class, this method runs all applicable player
    # conclude blocks and the narrative's own conclude blocks.
    # 
    # @return [void]
    def turn
      players.select(&:concluding?).each { |plyr| player_conclude_blocks.each { |blk| blk[plyr] } }
      conclude_blocks.each(&:call) if concluding?
    end

    # @return [String]
    def save
      Marshal.dump(self)
    end

    # @param snapshot [String]
    # @return [self]
    def self.restore(snapshot)
      Marshal.load(snapshot)
    end

    def self.inherited(klass)
      super
      klass.seeds.concat seeds
      klass.select_default_scene default_scene
      klass.select_default_conclusion default_conclusion
    end
  end
end
