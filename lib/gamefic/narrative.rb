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
    include Scriptable::Proxy
    include Scriptable::Queries
    include Scriptable::Scenes

    attr_reader :rulebook

    def initialize
      self.class.included_blocks.select(&:seed?).each { |blk| Stage.run self, &blk.code }
      self.class.appended_chapters.each do |klass|
        chapters.push klass.new(self)
      end
      entity_vault.lock
      @rulebook = nil
      hydrate
    end

    def chapters
      @chapters ||= []
    end

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
        scene.run_start_blocks player, nil
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
      @rulebook = Rulebook.new
      @rulebook.script_with_defaults self
      @rulebook.freeze
    end

    def self.inherited klass
      super
      klass.blocks.concat blocks
    end

    def self.append chapter
      appended_chapters.add chapter
    end

    def self.appended_chapters
      @appended_chapters ||= Set.new
    end
  end
end
