# frozen_string_literal: true

module Gamefic
  # The plot is the central narrative. It provides a script interface with
  # methods for creating entities, actions, scenes, and hooks.
  #
  # @!method self.script &block
  #   @yieldself [ScriptMethods]
  #
  class Plot < Narrative
    module ScriptMethods
      include Narrative::ScriptMethods
      include Delegatable::Plots
    end

    delegate ScriptMethods

    # @return [Array<Take>]
    def takes
      @takes ||= [].freeze
    end

    def ready
      @takes = players.map { |pl| pl.start_cue }.freeze
      takes.each(&:start)
      super
      subplots.each(&:ready)
      subplots.delete_if(&:concluding?)
      takes.each do |take|
        scenebook.run_player_conclude_blocks take.actor if take.conclusion?
        scenebook.run_player_output_blocks take.actor, take.output
        subplots.each { |sp| sp.scenebook.run_player_output_blocks take.actor, take.output }
        take.actor.output.merge! take.output
        take.actor.output.merge!({
          messages: take.actor.messages + take.output[:messages],
          queue: take.actor.queue
        })
      end
    end

    def update
      takes.each(&:finish)
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

    def cast_all
      super
      subplots.each(&:cast_all)
    end

    def uncast_all
      super
      subplots.each(&:uncast_all)
    end

    def inspect
      "#<#{self.class}>"
    end

    def save
      Snapshot.save self
    end

    def set_rules
      stage do
        block :default_scene, rig: Gamefic::Rig::Activity unless scenes.include?(:default_scene)
        block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenes.include?(:default_conclusion)
      end
      super
    end

    def self.restore snapshot
      Snapshot.restore snapshot
    end
  end
end
