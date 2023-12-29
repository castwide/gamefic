# frozen_string_literal: true

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    extend Scriptable

    include Logging
    include Delegatable::Entities
    include Delegatable::Queries

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
      rulebook.events.run_ready_blocks
    end

    def update
      rulebook.events.run_update_blocks
    end

    def instance_metadata
      instance_variables.map { |var| [var, instance_variable_get(var).inspect] }
                        .to_h
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
      # [entity_vault.array, player_vault.array].each(&:freeze)
      return unless rulebook.empty?

      self.class.included_blocks.select(&:script?).each { |blk| Stage.run(self, Delegatable::Scripting, &blk.code) }
    end

    def allow_mutation_in_scripts?
      self.class.allow_mutation_in_scripts?
    end

    def self.restrict_mutation_in_scripts
      @allow_mutation_in_scripts = false
    end

    def self.allow_unrestricted_mutation
      @allow_mutation_in_scripts = true
    end

    def self.allow_mutation_in_scripts?
      @allow_mutation_in_scripts ||= false
    end
  end
end
