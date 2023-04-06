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

    # @return [Playbook]
    attr_reader :playbook

    # @return [Scenebook]
    attr_reader :scenebook

    def initialize
      @playbook = Playbook.new
      @scenebook = Scenebook.new
      run_scripts
      setup.entities.hydrate
      setup.scenes.hydrate
      setup.actions.hydrate
      scenebook.add Scene.new(intro_name, rig: Gamefic::Rig::Activity) unless scenebook.scene?(intro_name)
    end

    # @param block [Proc]
    def stage &block
      @theater ||= Theater.new(self)
      @theater.instance_eval &block
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
      player.cue intro_name
    end

    def intro_name
      @intro_name ||= SecureRandom.uuid.to_sym
    end

    private

    def run_scripts
      self.class.blocks.each { |blk| stage(&blk) }
    end

    def setup
      @setup ||= Setup.new
    end
  end
end
