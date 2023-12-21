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
  #     seeds, they generally result in errors because rulebooks and scenebooks
  #     get frozen after the scripts get executed.
  #   @yieldself [Delegatable::Entities]
  class Narrative
    extend Scriptable

    module ScriptMethods
      include Delegatable::Actions
      include Delegatable::Entities
      include Delegatable::Queries
      include Delegatable::Scenes
      include Delegatable::Sessions
    end

    include Logging
    # @!parse include ScriptMethods
    delegate ScriptMethods

    # @return [Integer]
    attr_reader :digest

    # @return [Hash]
    attr_reader :config

    def initialize
      @session = {}
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

    # @return [Rulebook]
    def rulebook
      @rulebook || raise(RulebookError, 'Rulebooks can only be modified in scripts')
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

    # Add this narrative's rulebook and scenebook to an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.rulebooks.add rulebook
      active.scenebooks.add scenebook
      active
    end

    # Remove this narrative's rulebook and scenebook from an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.rulebooks.delete rulebook
      active.scenebooks.delete scenebook
      active
    end

    # Cast all players in the narrative.
    #
    # @see #cast
    #
    # @note This method does nothing if the rulebooks are undefined
    #
    def cast_all
      return unless @rulebook && @scenebook

      players.each { |plyr| cast plyr }
    end

    # Uncast all players in the narrative.
    #
    # @see #uncast
    #
    # @note This method does nothing if the rulebooks are undefined
    #
    def uncast_all
      return unless @rulebook && @scenebook

      players.each { |plyr| uncast plyr }
    end

    def ready
      scenebook.run_ready_blocks
    end

    def update
      scenebook.run_update_blocks
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
      @rulebook = Rulebook.new(method(:stage))
      @scenebook = Scenebook.new(method(:stage))
      self.class.blocks.select(&:script?).each { |blk| stage(&blk.proc) }
    end

    def set_rules
      rulebook.freeze
      scenebook.freeze
    end

    # Define a method that delegates an attribute reader to the stage.
    #
    # @example
    #   class MyNarrative < Gamefic::Narrative
    #     attr_delegate :npc
    #     seed { @npc = make Gamefic::Entity, name: 'npc' }
    #   end
    #
    #   narr = MyNarrative.new
    #   narr.npc #=> #<Gamefic::Entity npc>
    #
    def self.attr_delegate symbol
      define_method symbol do
        stage(symbol) { |sym| instance_variable_get("@#{sym}") }
      end
      delegate_method symbol
    end
  end
end
