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
      @rulebook ||= Rulebook.new(method(:stage))
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
      rulebook.events.run_player_conclude_blocks player
      uncast player
      player_vault.delete player
    end

    # Add this narrative's rulebook and scenebook to an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def cast active
      active.narratives.add self
      active
    end

    # Remove this narrative's rulebook from an active entity.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.narratives.delete self
      active
    end

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
      before = Marshal.dump([session, theater])
      self.class.blocks.select(&:script?).each { |blk| stage(&blk.proc) }
      after = Marshal.dump([session, theater])
      return if before == after

      logger.warn "#{self.class} data changed during script setup. Snapshots may not restore properly"
    end

    def set_rules
      rulebook.freeze
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

    UNMARSHALED_VARIABLES = [:@rulebook, :@takes].freeze

    def marshal_dump
      (instance_variables - UNMARSHALED_VARIABLES).inject({}) do |vars, attr|
        vars[attr] = instance_variable_get(attr)
        vars
      end
    end

    def marshal_load(vars)
      vars.each do |attr, value|
        instance_variable_set(attr, value) unless UNMARSHALED_VARIABLES.include?(attr)
      end
      run_scripts
      set_rules
      players.each { |plyr| cast plyr }
      theater.freeze
      entity_vault.array.freeze
      player_vault.array.freeze
    end
  end
end
