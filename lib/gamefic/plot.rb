# frozen_string_literal: true

module Gamefic
  class Plot < Assembly
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host,      'gamefic/plot/host'

    include Host
    include Snapshot

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
      @started = true
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

    def inspect
      "#<#{self.class}>"
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
  end
end

module Gamefic
  # A shortcut to `Gamefic::Plot.script`
  #
  def self.script &block
    Gamefic::Plot.script &block
  end
end
