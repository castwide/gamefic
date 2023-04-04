module Gamefic
  # A collection of methods that are common to plots and subplots.
  module Direction
    include Scripting
    extend Scripting::ClassMethods

    # Introduce a player to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      @introduced = true
      player.playbooks.push playbook unless player.playbooks.include?(playbook)
      player.scenebooks.push scenebook unless player.scenebooks.include?(scenebook)
      players_safe_push player
      player.select_cue :introduction, default_scene
    end

    def start_production
      @entities = [].freeze
      @players = [].freeze
      @playbook = Playbook.new
      @scenebook = Scenebook.new
      run_scripts
      default_scene && default_conclusion # Make sure they exist
      playbook.freeze
      scenebook.freeze
      @initialized = true
    end

    def initialized?
      !!@initialized
    end

    # @param actor [Actor]
    # @return [Actor]
    def exeunt actor
      scenebook.player_conclude_blocks.each { |blk| blk.call actor }
      actor.scenebooks.delete scenebook
      actor.playbooks.delete playbook
      players_safe_delete actor
    end

    private

    def entities_safe_push entity
      @entities = @entities.dup.push(entity).freeze
    end

    def players_safe_push player
      @players = @players.dup.push(player).freeze
    end

    def entities_safe_delete entity
      @entities = (@entities.dup - [entity]).freeze
    end

    def players_safe_delete player
      @players = (@players.dup - [player]).freeze
    end
  end
end
