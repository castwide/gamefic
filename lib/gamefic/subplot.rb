require 'gamefic/plot'

module Gamefic
  class Subplot #< Container
    include World

    # @return [Gamefic::Plot]
    attr_reader :plot

    class << self
      def script &block
        structure.script &block
      end

      def structure
        @structure ||= Structure.new
      end
    end

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor]
    # @param next_cue [Class<Gamefic::Scene::Base>]
    def initialize plot, introduce: nil, next_cue: nil, **more
      @plot = plot
      @next_cue = next_cue
      @concluded = false
      configure more
      self.class.structure.blocks.each { |blk| stage &blk }
      playbook.freeze
      self.introduce introduce unless introduce.nil?
    end

    def players
      p_players
    end

    def add_entity e
      @p_entities.push e
    end

    def subplot
      self
    end

    def default_scene
      plot.default_scene
    end

    def default_conclusion
      plot.default_conclusion
    end

    def playbook
      @playbook ||= Gamefic::Plot::Playbook.new
    end

    def cast cls, args = {}, &block
      ent = super
      ent.playbooks.push plot.playbook unless ent.playbooks.include?(plot.playbook)
      ent
    end

    # HACK: Always assume subplots are running for the sake of entity destruction
    def running?
      true
    end

    def exeunt player
      player.playbooks.delete playbook
      player.cue (@next_cue || default_scene)
      p_players.delete player
    end

    def conclude
      @concluded = true
      entities.each { |e|
        destroy e
      }
      players.each { |p|
        exeunt p
      }
    end

    def concluded?
      @concluded
    end

    def ready
      conclude if players.empty?
      return if concluded?
      playbook.freeze
      call_ready
      call_player_ready
    end

    def update
      call_player_update
      call_update
    end

    private

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure more
    end
  end
end
