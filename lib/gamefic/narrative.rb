# frozen_string_literal: true

module Gamefic
  class RulebookError < RuntimeError; end

  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  # @!method self.script &block
  #   @yieldself [ScriptMethods]
  #
  # @!method self.seed &block
  #   @note Although methods related to actions and scenes are available in
  #     seeds, they generally result in errors because playbooks and scenebooks
  #     get frozen after the scripts get executed.
  #   @yieldself [Delegatable::Entities]
  class Narrative
    extend Scriptable

    module ScriptMethods
      include Delegatable::Actions
      include Delegatable::Entities
      include Delegatable::Queries
      include Delegatable::Scenes
    end

    include Logging
    # @!parse include ScriptMethods
    delegate ScriptMethods

    # @return [Integer]
    attr_reader :digest

    # @return [Hash]
    attr_reader :config

    def initialize
      run_seeds
      set_seeds
      run_scripts
      set_rules
    end

    def entity_vault
      @entity_vault ||= Vault.new
    end

    def player_vault
      @player_vault ||= Vault.new
    end

    def theater
      @theater ||= Theater.new
    end

    # @return [Playbook]
    def playbook
      @playbook || raise(RulebookError, 'Playbooks can only be modified in scripts')
    end

    # @return [Scenebook]
    def scenebook
      @scenebook || raise(RulebookError, 'Scenebooks can only be modified in scripts')
    end

    # @param block [Proc]
    def stage *args, &block
      theater.evaluate self, *args, block
    end

    # Introduce an actor to the story.
    #
    # @param [Gamefic::Actor]
    # @return [void]
    def introduce(player)
      enter player
      scenebook.introductions.each do |scene|
        take = Take.new(player, scene)
        take.start
        player.stream take.output[:messages]
      end
    end

    # A narrative is considered to be concluding when all of its players are in
    # a conclusion scene. Engines can use this method to determine whether the
    # game is ready to end.
    #
    def concluding?
      players.empty? || players.all?(&:concluding?)
    end

    # Add a player to the game.
    #
    # @param player [Active]
    def enter player
      cast player
      player_vault.add player
    end

    # Remove a player from the game.
    #
    def exeunt player
      scenebook.run_player_conclude_blocks player
      uncast player
      player_vault.delete player
    end

    # Add this narrative's playbook and scenebook to an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.playbooks.add playbook
      active.scenebooks.add scenebook
      active
    end

    # Remove this narrative's playbook and scenebook from an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.playbooks.delete playbook
      active.scenebooks.delete scenebook
      active
    end

    # Cast all players in the narrative.
    #
    # @see #cast
    #
    def cast_all
      players.each { |plyr| cast plyr }
    end

    # Uncast all players in the narrative.
    #
    # @see #uncast
    #
    def uncast_all
      players.each { |plyr| uncast plyr }
    end

    def ready
      scenebook.run_ready_blocks
    end

    def update
      scenebook.run_update_blocks
    end

    # Get a proxy for an entity.
    #
    # @raise [RuntimeError] if the entity is not found in the narrative
    #
    # @param entity [Entity]
    # @return [Proxy]
    def proxy entity
      logger.debug "Proxying #{entity.inspect}"
      index = entities.find_index(entity)
      raise "#{entity.inspect} could not be proxied" unless index

      Proxy.new(self, index)
    end

    # @return [void]
    def run_seeds
      self.class.blocks.select(&:seed?).each { |blk| stage(&blk.proc) }
    end

    def set_seeds
      entity_vault.lock
      @digest = Gamefic::Snapshot.digest(self).freeze
      theater.freeze
    end

    # @return [void]
    def run_scripts
      @playbook = Playbook.new(method(:stage))
      @scenebook = Scenebook.new(method(:stage))
      seed_length = entities.length
      self.class.blocks.select(&:script?).each { |blk| stage(&blk.proc) }
      return if entities.length == seed_length

      logger.warn "Entities were created or deleted in scripts. Using `seed` to manage entities is recommended"
    end

    def set_rules
      playbook.freeze
      scenebook.freeze
    end
  end
end
