# frozen_string_literal: true

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  # @!method self.script &block
  #   @yieldself [ScriptMethods]
  #
  # @!method self.seed &block
  #   @note Although methods related to actions and scenes are available in
  #     seeds, they generally result in errors because rulebooks get frozen
  #     after the scripts get executed.
  #   @yieldself [Delegatable::Entities]
  class Narrative
    extend Scriptable


    include Logging
    include Delegatable::Entities

    def initialize
      rulebook
      self.class.included_blocks.that_are(Block::Seed).each { |blk| blk.build self }
      self.class.included_blocks.that_are(Block::Script).each { |blk| blk.build self }
    end

    def entity_vault
      @entity_vault ||= Vault.new
    end

    def player_vault
      @player_vault ||= Vault.new
    end

    # @return [Rulebook]
    def rulebook
      @rulebook ||= Rulebook.new(self)
    end

    def scenes
      rulebook.scenes.names
    end

    # @param block [Proc]
    def stage *args, &block
      instance_exec(*args, &block)
    end

    # Introduce an actor to the story.
    #
    # @param player [Gamefic::Actor]
    # @return [Gamefic::Actor]
    def introduce(player = Gamefic::Actor.new)
      enter player
      rulebook.scenes.introductions.each do |scene|
        take = Take.new(player, scene)
        take.start
        player.stream take.output[:messages]
      end
      player
    end

    # A narrative is considered to be concluding when all of its players are in
    # a conclusion scene. Engines can use this method to determine whether the
    # game is ready to end.
    #
    def concluding?
      players.empty? || players.all?(&:concluding?)
    end

    # Add an active entity to the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.narratives.add self
      player_vault.add active
      active
    end
    alias enter cast

    # Remove an active entity from the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.narratives.delete self
      player_vault.delete active
      active
    end
    alias exeunt uncast

    def ready
      rulebook.events.run_ready_blocks
    end

    def update
      rulebook.events.run_update_blocks
    end

    def instance_metadata
      instance_variables.map { |var| [var, instance_variable_get(var).inspect] }
                        .to_h
    end

    def freeze?
      freeze unless RUBY_ENGINE == 'opal'
      self
    end
  end
end
