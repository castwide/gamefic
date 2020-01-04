require 'gamefic/plot'

module Gamefic
  class Subplot #< Container
    include World
    include Scriptable
    # @!parse extend Scriptable::ClassMethods

    # @return [Gamefic::Plot]
    attr_reader :plot

    # @param plot [Gamefic::Plot]
    # @param introduce [Gamefic::Actor]
    # @param next_cue [Class<Gamefic::Scene::Base>]
    def initialize plot, introduce: nil, next_cue: nil, **more
      @plot = plot
      @next_cue = next_cue
      @concluded = false
      configure more
      run_scripts
      playbook.freeze
      self.introduce introduce unless introduce.nil?
    end

    def players
      @players ||= []
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

    def exeunt player
      player_conclude_procs.each { |block| block.call player }
      player.playbooks.delete playbook
      player.cue (@next_cue || default_scene)
      players.delete player
    end

    def conclude
      @concluded = true
      # Players needed to exit first in case any player_conclude procs need to
      # interact with the subplot's entities.
      players.each { |p| exeunt p }
      # @todo I'm not sure why rejecting nils is necessary here. It's only an
      #   issue in Opal.
      entities.reject(&:nil?).each { |e| destroy e }
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
