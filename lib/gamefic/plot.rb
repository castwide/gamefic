# frozen_string_literal: true

module Gamefic
  class Plot
    autoload :Snapshot,  'gamefic/plot/snapshot'
    autoload :Darkroom,  'gamefic/plot/darkroom'
    autoload :Host, 'gamefic/plot/host'

    include Direction
    extend Scripting::ClassMethods
    include Host

    # @return [Hash]
    attr_reader :metadata

    def initialize
      start_production
      # run_scripts
      # default_scene && default_conclusion # Make sure they exist
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

    def takes
      @takes ||= []
    end

    def ready
      subplots.delete_if(&:concluded?)
      scenebook.ready_blocks.each(&:call)
      prepare_takes
      start_takes
    end

    def update
      finish_takes
      players.each do |plyr|
        scenebook.player_update_blocks.each { |blk| blk.call plyr }
      end
      scenebook.update_blocks.each(&:call)
    end

    # @param plot [Plot]
    # @param block [Proc]
    def stage &block
      # Scripts can share some information like instance variables before the
      # plot gets instantiated, but running plots should not.
      if initialized?
        @stage = nil
        Theater.new(self).instance_eval &block
      else
        @stage ||= Theater.new(self)
        @stage.tap { |stg| stg.instance_eval(&block) }
      end
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

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The class of the subplot to be created (Subplot by default)
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil, next_cue: nil, **more
      subplot = subplot_class.new(self, introduce: introduce, next_cue: next_cue, **more)
      subplots.push subplot
      subplot
    end

    private

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
  end
end

module Gamefic
  def self.script &block
    Gamefic::Plot.script &block
  end
end
