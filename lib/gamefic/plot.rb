# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  # @!method self.script &block
  #   @yieldself [ScriptMethods]
  #
  class Plot < Narrative
    # A collection of methods that are delegated to plots from theaters.
    #
    module ScriptMethods
      include Narrative::ScriptMethods
      include Delegatable::Plots
    end

    # @!parse include ScriptMethods
    # @!method self.script &block
    #   @see Gamefic::Scriptable#script
    #   @yieldself [ScriptMethods]
    # @!method self.seed &block
    #   @see Gamefic::Scriptable#seed
    #   @yieldself [ScriptMethods]
    delegate ScriptMethods

    def ready
      players.each(&:start_take)
      super
      subplots.each(&:ready)
      subplots.delete_if(&:concluding?)
      players.select(&:concluding?).each { |plyr| rulebook.events.run_player_conclude_blocks plyr }
    end

    def update
      players.each(&:finish_take)
      super
      subplots.each(&:update)
    end

    # Make a character that a player will control on introduction.
    #
    # @return [Gamefic::Actor]
    def make_player_character
      Gamefic::Actor.new name: 'yourself', synonyms: 'yourself self myself you me', proper_named: true
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
      subplots_featuring(actor).each { |sp| sp.exeunt actor }
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

    def run_scripts
      super
      stage do
        block :default_scene, rig: Gamefic::Rig::Activity unless scenes.include?(:default_scene)
        block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenes.include?(:default_conclusion)
      end
    end

    def self.restore data
      Snapshot.restore data
    end
  end
end
