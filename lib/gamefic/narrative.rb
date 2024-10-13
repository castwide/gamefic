# frozen_string_literal: true

require 'set'

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    require 'gamefic/narrative/proxies'
    require 'gamefic/narrative/entities'
    require 'gamefic/narrative/scripts'

    extend Scriptable

    include Entities
    include Scripts

    include Logging
    include Scriptable::Queries

    select_default_scene Scene::Activity
    select_default_conclusion Scene::Conclusion

    bind *(Narrative::Entities.public_instance_methods)

    def initialize
      seeds.each { |blk| instance_exec(&blk) }
      post_script
    end

    def script
      included_blocks.select(&:script?).each { |blk| Stage.run self, &blk.code }
    end

    # @return [Array<Module>]
    def included_blocks
      self.class.included_blocks
    end

    def post_script
      entity_vault.lock
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
      introductions.each { |blk| blk[player] }
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
      entity_vault.add active
      active
    end

    # Remove an active entity from the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast active
      active.narratives.delete self
      player_vault.delete active
      entity_vault.delete active
      active
    end

    def ready
      self.class.included_scripts
                .flat_map(&:ready_blocks)
                .concat(self.class.ready_blocks)
                .each { |block| Stage.run(self, &block) }
    end

    def update
      self.class.included_scripts
                .flat_map(&:update_blocks)
                .concat(self.class.update_blocks)
                .each { |block| Stage.run(self, &block) }
    end

    def hydrate
      script
      post_script
    end

    def verbs
      self.class.responses.map(&:verb).uniq
    end

    def bound_methods
      self.class.bound_methods.to_a
    end

    def bound? method
      self.class.bound_methods.include?(method)
    end

    def self.inherited klass
      super
      klass.seeds.concat seeds
      klass.select_default_scene default_scene
      klass.select_default_conclusion default_conclusion
      klass.bind *bound_methods
    end
  end
end
