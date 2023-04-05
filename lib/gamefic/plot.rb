# frozen_string_literal: true

module Gamefic
  class Plot < Assembly
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host,      'gamefic/plot/host'

    include Scriptable
    include Host
    include Snapshot

    # @return [Hash]
    attr_reader :metadata

    def takes
      @takes ||= []
    end

    # Introduce a player to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      @introduced = true
      player.playbooks.push playbook unless player.playbooks.include?(playbook)
      player.scenebooks.push scenebook unless player.scenebooks.include?(scenebook)
      players_safe_push player
      player.cue @introduction || default_scene
    end

    # Cast an active entity.
    # This method is similar to make, but it also provides the plot's
    # playbook and scenebook to the entity so it can perform actions and
    # participate in scenes. The entity should be an instance of
    # Gamefic::Actor or include the Gamefic::Active module.
    #
    # @return [Gamefic::Actor, Gamefic::Active]
    def cast cls, **args
      ent = make cls, **args
      ent.playbooks.push playbook
      ent.scenebooks.push scenebook
      ent
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

    def prepare_takes
      takes.replace(players.map do |pl|
        pl.start_cue default_scene
      end)
    end

    def start_takes
      takes.each do |take|
        scenebook.run_player_ready_blocks take.actor
        take.start
        scenebook.run_player_output_blocks take.actor, take.output
      end
    end

    def finish_takes
      takes.each do |take|
        take.finish
        next if take.cancelled? || take.scene.type != 'Conclusion'

        exeunt take.actor
      end
      takes.clear
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
  end
end

module Gamefic
  def self.script &block
    Gamefic::Plot.script &block
  end
end
