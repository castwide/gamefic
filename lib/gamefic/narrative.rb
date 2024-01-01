# frozen_string_literal: true

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    extend Scriptable

    include Logging
    include Delegatable::Actions
    include Delegatable::Entities
    include Delegatable::Events
    include Delegatable::Queries
    include Delegatable::Scenes

    attr_reader :rulebook

    def initialize
      self.class.included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
      hydrate
    end

    def entity_vault
      @entity_vault ||= Vault.new
    end

    def player_vault
      @player_vault ||= Vault.new
    end

    def scenes
      rulebook.scenes.names
    end

    # Introduce an actor to the story.
    #
    # @param player [Gamefic::Actor]
    # @return [Gamefic::Actor]
    def introduce(player = Gamefic::Actor.new)
      enter player
      rulebook.scenes.introductions.each do |scene|
        props = Take.start(player, scene, {})
        player.stream props.output[:messages]
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
      active.epic.add self
      player_vault.add active
      active
    end
    alias enter cast

    # Remove an active entity from the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.epic.delete self
      player_vault.delete active
      active
    end
    alias exeunt uncast

    def ready
      rulebook.run_ready_blocks
    end

    def update
      rulebook.run_update_blocks
    end

    # @return [Object]
    def detach
      cache = @rulebook
      @rulebook = nil
      cache
    end

    def attach cache
      @rulebook = cache
    end

    def hydrate
      [entity_vault.array, player_vault.array].each(&:freeze)

      @rulebook = Rulebook.new(self)
      @rulebook.script_with_defaults
      @rulebook.freeze
    end

    def self.inherited klass
      klass.blocks.concat blocks
    end
  end
end
