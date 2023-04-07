# frozen_string_literal: true

require 'base64'

module Gamefic
  class Plot < Assembly
    # @return [Hash]
    attr_reader :metadata

    def initialize metadata = {}
      super()
      @metadata = metadata
      block_default_scenes
      playbook.freeze
      scenebook.freeze
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
      # @todo Should we even bother with player_class? This could stand to be
      #   more robust, but the adjustable player class seems like a step too
      #   far.
      make Gamefic::Actor, name: 'yourself', synonyms: 'self myself you me', proper_named: true
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
    # @param subplot_class [Class<Gamefic::Subplot>] The class of the subplot to be created (Subplot by default)
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil, next_cue: nil, **more
      subplot = subplot_class.new(self, introduce: introduce, next_cue: next_cue, **more)
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

    def save
      binary = Marshal.dump(self)
      Base64.encode64(binary)
    end

    def marshal_dump
      {
        plot: {
          entities: entities,
          players: players,
          theater: instance_variable_get(:@theater)
        },
        subplots: subplots.map do |sp|
          {
            klass: sp.class,
            entities: sp.entities,
            players: sp.players,
            theater: sp.instance_variable_get(:@theater)
          }
        end
      }
    end

    def marshal_load data
      rebuild self, data[:plot]
      data[:subplots].each do |subdata|
        subplot = subdata[:klass].allocate
        rebuild subplot, subdata
        subplots.push subplot
      end
    end

    def self.restore snapshot
      binary = Base64.decode64(snapshot)
      Marshal.load(binary)
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

    def block_default_scenes
      block :default_scene, rig: Gamefic::Rig::Activity unless scenebook.scene?(:default_scene)
      block :default_conclusion, rig: Gamefic::Rig::Conclusion unless scenebook.scene?(:default_conclusion)
    end

    def rebuild part, data
      part.instance_variable_set(:@entities, data[:entities])
      part.instance_variable_set(:@players, data[:players])
      part.instance_variable_set(:@theater, data[:theater])
      part.players.each do |plyr|
        plyr.playbooks.push part.playbook
        plyr.scenebooks.push part.scenebook
      end
      part.run_scripts
      part.setup.entities.discard
      part.setup.scenes.hydrate
      part.setup.actions.hydrate
    end
  end
end
