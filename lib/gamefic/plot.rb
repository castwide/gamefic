# frozen_string_literal: true

require 'base64'

module Gamefic
  # @!method self.script &block
  #   Plot scripting
  #   @yieldself [Scriptable::Actions, Scriptable::Branches, Scriptable::Queries, Scriptable::Scenes]
  #
  class Plot < Narrative
    module ScriptMethods
      include Scriptable::Actions
      include Scriptable::Entities
      include Scriptable::Plots
      include Scriptable::Queries
      include Scriptable::Scenes
    end

    include ScriptMethods

    # @return [Hash]
    attr_reader :metadata

    def initialize metadata = {}
      super(ScriptMethods.public_instance_methods)
      @metadata = metadata
    end

    # @return [Array<Take>]
    def takes
      @takes ||= [].freeze
    end

    def ready
      subplots.each(&:ready)
      subplots.delete_if(&:concluding?)
      super
      start_takes
    end

    def update
      subplots.each(&:update)
      finish_takes
      super
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

    def save
      Snapshot.save self
    end

    def run_scripts
      super
      stage do
        block :default_scene, rig: Gamefic::Rig::Activity unless scenes.include?(:default_scene)
        block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenes.include?(:default_conclusion)
      end
    end

    def self.restore snapshot
      Snapshot.restore snapshot
    end

    private

    def start_takes
      @takes = players.map { |pl| pl.start_cue }.freeze
      takes.each do |take|
        take.start
        scenebook.run_player_conclude_blocks take.actor if take.conclusion?
        scenebook.run_player_output_blocks take.actor, take.output
        take.actor.output.merge! take.output
        take.actor.output.merge!({
          messages: take.output[:messages] + take.actor.messages,
          queue: take.actor.queue
        })
      end
    end

    def finish_takes
      takes.each do |take|
        take.actor.flush
        next if take.cancelled?

        take.finish
      end
      @takes = [].freeze
    end
  end
end

module Gamefic
  # A shortcut to `Gamefic::Plot.script`
  #
  # @yieldself [Scriptable::Actions, Scriptable::Branches, Scriptable::Queries, Scriptable::Scenes]
  def self.script &block
    Gamefic::Plot.script &block
  end
end
