# frozen_string_literal: true

require 'set'

module Gamefic
  # A base class for building and managing the resources that compose a story.
  # The Plot and Subplot classes inherit from Narrative and provide additional
  # functionality.
  #
  class Narrative
    include Scripting

    include Logging

    select_default_scene Scene::Activity
    select_default_conclusion Scene::Conclusion

    # Construct an entity.
    #
    # @return [void]
    def self.construct name, klass, **opts
      ivname = "@#{name}"
      define_method(name) do
        return instance_variable_get(ivname) if instance_variable_defined?(ivname)

        instance_variable_set(ivname, make(klass, **unproxy(opts)))
      end
      bind name
      seed { send(name) }
      define_singleton_method(name) { Proxy::Attr.new(name) }
    end

    class << self
      # @todo These aliases might be removed before the 4.0 release
      alias bind_make construct
      alias attr_make construct
      alias attr_seed construct
    end

    # Lazy pick an entity.
    #
    # @example
    #   pick('the red box')
    #
    # @param args [Array]
    # @return [Proxy]
    def self.pick *args
      Proxy::Pick.new(*args)
    end
    class << self
      alias lazy_pick pick
    end

    # Lazy pick an entity or raise an error
    #
    def self.pick! *args
      Proxy::Pick.new(*args)
    end
    class << self
      alias lazy_pick! pick
    end

    def self.seeds
      @seeds ||= []
    end

    def self.seed(&block)
      seeds.push block
    end

    def initialize
      seeds.each { |blk| instance_exec(&blk) }
      post_script
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
    def cast(active)
      active.narratives.add self
      player_vault.add active
      entity_vault.add active
      active
    end

    # Remove an active entity from the narrative.
    #
    # @param [Gamefic::Active]
    # @return [Gamefic::Active]
    def uncast(active)
      active.narratives.delete self
      player_vault.delete active
      entity_vault.delete active
      active
    end

    def ready
      find_and_bind(:ready_blocks).each(&:call)
    end

    def update
      find_and_bind(:update_blocks).each(&:call)
    end

    def verbs
      self.class.responses.map(&:verb).uniq
    end

    def self.inherited(klass)
      super
      klass.seeds.concat seeds
      klass.select_default_scene default_scene
      klass.select_default_conclusion default_conclusion
      klass.bind(*bound_methods)
    end
  end
end
