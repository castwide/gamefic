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
