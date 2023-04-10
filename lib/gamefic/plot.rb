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
      include Scriptable::Branches
      include Scriptable::Entities
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

    # A plot is considered to be concluding when all of its players are in one
    # of its conclusion scenes. Engines can use this method to determine when
    # the game is ready to end.
    #
    # @todo This is a first implementation, subject to change.
    #
    def concluding?
      takes.any? && takes.all? { |t| scenebook.scenes.include?(t.scene) && t.conclusion? }
    end

    def ready
      subplots.delete_if(&:concluded?)
      subplots.each(&:ready)
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
      # scenebook.player_conclude_blocks.each { |blk| blk.call actor }
      super
    end

    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      @subplots ||= []
    end

    # Get the player's current subplots.
    #
    # @return [Array<Subplot>]
    def subplots_featuring player
      result = []
      subplots.each { |s|
        result.push s if s.players.include?(player)
      }
      result
    end

    # Determine whether the player is involved in a subplot.
    #
    # @return [Boolean]
    def in_subplot? player
      !subplots_featuring(player).empty?
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
        scenebook.run_player_output_blocks take.actor, take.output
        take.actor.output.merge! take.output
        scenebook.run_player_conclude_blocks take.actor if take.conclusion?
      end
    end

    def finish_takes
      takes.each do |take|
        take.finish
        next if take.cancelled? || take.scene.type != 'Conclusion'

        exeunt take.actor
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
