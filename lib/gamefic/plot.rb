# frozen_string_literal: true

require 'base64'

module Gamefic
  class Plot < Assembly
    include Scriptable::Actions
    # include   Scriptable::Branches.public_instance_methods +
    include Scriptable::Entities
    include Scriptable::Queries
    include Scriptable::Scenes

    # @return [Hash]
    attr_reader :metadata

    def initialize metadata = {}
      super()
      @metadata = metadata
      block_default_scenes
      playbook.freeze
      scenebook.freeze
      @static_size = entities.length
    end

    def director
      @director ||= Director.new(self,
                                 Scriptable::Actions.public_instance_methods +
                                 #  Scriptable::Branches.public_instance_methods +
                                 Scriptable::Entities.public_instance_methods +
                                 Scriptable::Queries.public_instance_methods +
                                 Scriptable::Scenes.public_instance_methods +
                                 [:branch])
    end

    # @return [Array<Take>]
    def takes
      @takes ||= [].freeze
    end

    def ready
      subplots.delete_if(&:concluded?)
      subplots.each(&:ready)
      scenebook.ready_blocks.each(&:call)
      prepare_takes
      start_takes
    end

    def update
      subplots.each(&:update)
      finish_takes
      players.each do |plyr|
        scenebook.player_update_blocks.each { |blk| blk.call plyr }
      end
      scenebook.update_blocks.each(&:call)
    end

    # Make a character that a player will control on introduction.
    #
    # @return [Gamefic::Actor]
    def make_player_character
      Gamefic::Actor.new name: 'yourself', synonyms: 'yourself self myself you me', proper_named: true
    end

    # @param actor [Actor]
    # @return [Actor]
    def exeunt actor
      scenebook.player_conclude_blocks.each { |blk| blk.call actor }
      actor.scenebooks.delete scenebook
      actor.playbooks.delete playbook
      players_safe_delete actor
    end

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The Subplot class
    # @param introduce [Gamefic::Actor, Array<Gamefic::Actor>, nil] Players to introduce
    # @param config [Hash] Subplot configuration
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil, **config
      subplot = subplot_class.new(self, introduce: introduce, **config)
      subplots.push subplot
      subplot
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

    def block_default_scenes
      block :default_scene, rig: Gamefic::Rig::Activity unless scenebook.scene?(:default_scene)
      block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenebook.scene?(:default_conclusion)
    end

    def save
      Snapshot.save self
    end

    def self.restore snapshot
      Snapshot.restore snapshot
    end

    private

    def prepare_takes
      @takes = players.map { |pl| pl.start_cue }.freeze
    end

    def start_takes
      takes.each do |take|
        scenebook.run_player_ready_blocks take.actor
        take.start
        scenebook.run_player_output_blocks take.actor, take.output
        take.actor.output.replace take.output
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
