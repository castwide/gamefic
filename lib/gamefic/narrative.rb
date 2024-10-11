# frozen_string_literal: true

require 'set'

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    extend Scriptable

    include Logging
    include Scriptable::Actions
    include Scriptable::Entities
    include Scriptable::Events
    include Scriptable::Proxies
    include Scriptable::Queries
    include Scriptable::Scenes

    attr_reader :rulebook

    def initialize(hydrate: true)
      return unless hydrate

      seed
      script
      post_script
    end

    def seed
      included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
    end

    def script
      @rulebook = Rulebook.new
      included_blocks.select(&:script?).each { |blk| Stage.run self, &blk.code }
    end

    # @return [Array<Module>]
    def included_blocks
      self.class.included_blocks
    end

    def responses
      self.class
          .included_scripts
          .flat_map(&:responses)
          .concat(self.class.responses)
          .map { |resp| resp.bind self }
    end

    def post_script
      entity_vault.lock
      rulebook.freeze
    end

    # @return [Array<Symbol>]
    def scenes
      rulebook.scenes.names
    end

    # Introduce an actor to the story.
    #
    # @param player [Gamefic::Actor]
    # @return [Gamefic::Actor]
    def introduce(player = Gamefic::Actor.new)
      cast player
      rulebook.scenes.introductions.each do |scene|
        scene.new(player).run_start_blocks
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
      entity_vault.add active
      active
    end

    # Remove an active entity from the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.epic.delete self
      player_vault.delete active
      entity_vault.delete active
      active
    end

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
      script
      post_script
    end

    def self.inherited klass
      super
      klass.blocks.concat blocks
    end
  end
end
