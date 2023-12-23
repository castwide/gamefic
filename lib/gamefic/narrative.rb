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

    def initialize
      @session = {}
      run_seeds
      set_seeds
      run_scripts
      rulebook.freeze
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
      Rulebook::Registry.register self
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
      rulebook.scenes.introductions.each do |scene|
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

    # Cast all players in the narrative.
    #
    # @see #cast
    #
    # @note This method does nothing if the rulebooks are undefined
    #
    def cast_all
      players.each { |plyr| cast plyr }
    end

    # Uncast all players in the narrative.
    #
    # @see #uncast
    #
    # @note This method does nothing if the rulebooks are undefined
    #
    def uncast_all
      players.each { |plyr| uncast plyr }
    end

    def ready
      rulebook.events.run_ready_blocks
    end

    def update
      rulebook.events.run_update_blocks
    end

    # @return [void]
    def run_seeds
      self.class.blocks.select(&:seed?).each { |blk| stage(&blk.proc) }
    end

    def set_seeds
      entity_vault.lock
      @digest = Gamefic::Snapshot.digest(self).freeze
      theater.freeze
      return if rulebook.empty?

      logger.warn "Rulebook was modified in seeds. Snapshots may not restore properly"
    end

    # @return [void]
    def run_scripts
      before = instance_metadata
      self.class.blocks.select(&:script?).each { |blk| stage(&blk.proc) }
      return if before == instance_metadata

      logger.warn "#{self.class} data changed during script setup. Snapshots may not restore properly"
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

    private

    def instance_metadata
      [entities.inspect, session.inspect, theater.instance_metadata]
    end
  end
end
