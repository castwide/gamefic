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

    include ScriptMethods

    def initialize
      super
      block :default_scene, rig: Gamefic::Rig::Activity unless scenes.include?(:default_scene)
      block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenes.include?(:default_conclusion)
    end

    def ready
      super
      subplots.each(&:ready)
      players.each(&:start_take)
      subplots.delete_if(&:concluding?)
      players.select(&:concluding?).each { |plyr| rulebook.events.run_player_conclude_blocks plyr }
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

    def self.restore data
      Snapshot.restore data
    end
  end
end
