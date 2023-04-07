require 'securerandom'

module Gamefic
  # A base class for managing the resources that compose plots and subplots.
  #
  class Assembly
    class << self
      def blocks
        @blocks ||= []
      end

      def script &block
        blocks.push block
      end
    end

    include Scriptable

    def initialize
      @playbook = Playbook.new
      @scenebook = Scenebook.new
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
      scenebook.add Scene.new(intro_name, rig: Gamefic::Rig::Activity) unless scenebook.scene?(intro_name)
    end

    # @return [Playbook]
    def playbook
      @playbook ||= Playbook.new
    end

    # @return [Scenebook]
    def scenebook
      @scenebook ||= Scenebook.new
    end

    # @param block [Proc]
    def stage &block
      @theater ||= Theater.new(self)
      @theater.instance_eval &block
    end

    # Introduce an actor to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      cast player
      players_safe_push player
      player.cue intro_name
    end

    # Remove a player from the game.
    #
    def exeunt player
      uncast player
      players_safe_delete player
    end

    # Add this assembly's playbook and scenebook to an active entity.
    #
    # @return [Gamefic::Active]
    def cast active
      active.playbooks.push playbook
      active.scenebooks.push scenebook
      active
    end

    def uncast active
      active.playbooks.delete playbook
      active.scenebooks.delete scenebook
    end

    def intro_name
      @intro_name ||= SecureRandom.uuid.to_sym
    end

    def run_scripts
      self.class.blocks.each { |blk| stage(&blk) }
      @static_size = entities.length
    end

    def setup
      @setup ||= Setup.new
    end
  end
end
