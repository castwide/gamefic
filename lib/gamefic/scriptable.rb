# frozen_string_literal: true

require 'set'

module Gamefic
  # A class module that enables scripting.
  #
  # Narratives extend Scriptable to enable definition of scripts and seeds.
  # Modules can also be extended with Scriptable to make them includable to
  # other Scriptables.
  #
  # @example Include a scriptable module in a plot
  #   module MyScript
  #     extend Gamefic::Scriptable
  #
  #     respond :myscript do |actor|
  #       actor.tell "This command was added by MyScript"
  #     end
  #   end
  #
  #   class MyPlot < Gamefic::Plot
  #     include MyScript
  #   end
  #
  module Scriptable
    autoload :Actions,   'gamefic/scriptable/actions'
    autoload :Entities,  'gamefic/scriptable/entities'
    autoload :Events,    'gamefic/scriptable/events'
    autoload :Queries,   'gamefic/scriptable/queries'
    autoload :Proxy,     'gamefic/scriptable/proxy'
    autoload :Scenes,    'gamefic/scriptable/scenes'

    include Proxy
    include Queries
    # @!parse
    #   include Scriptable::Actions
    #   include Scriptable::Events
    #   include Scriptable::Scenes

    # @return [Array<Block>]
    def blocks
      @blocks ||= []
    end
    alias scripts blocks

    # Add a block of code to be executed during initialization.
    #
    # These blocks are primarily used to define actions, scenes, and hooks in
    # the narrative's rulebook. Entities and game data should be initialized
    # with `seed`.
    #
    # @example
    #   class MyPlot < Gamefic::Plot
    #     script do
    #       introduction do |actor|
    #         actor.tell 'Hello, world!'
    #       end
    #
    #       respond :wait do |actor|
    #         actor.tell 'Time passes.'
    #       end
    #     end
    #   end
    #
    def script &block
      blocks.push Block.new(:script, block)
    end

    # Add a block of code to generate content after initialization.
    #
    # Seeds run after the initial scripts have been executed. Their primary
    # use is to add entities and other data components, especially randomized
    # or procedurally generated content that can vary between instances.
    #
    # @note Seeds do not get executed when a narrative is restored from a
    #   snapshot.
    #
    # @example
    #   class MyPlot < Gamefic::Plot
    #     seed do
    #       @thing = make Gamefic::Entity, name: 'a thing'
    #     end
    #   end
    #
    def seed &block
      blocks.push Block.new(:seed, block)
    end

    # @return [Array<Block>]
    def included_blocks
      included_modules.that_are(Scriptable)
                      .uniq
                      .reverse
                      .flat_map(&:blocks)
                      .concat(blocks)
    end

    # Seed an entity.
    #
    # @example
    #   make_seed Gamefic::Entity, name: 'thing'
    #
    # @param klass [Class<Gamefic::Entity>]
    def make_seed klass, **opts
      @count ||= 0
      seed { make(klass, **opts) }
      Proxy::Agent.new(@count.tap { @count += 1 })
    end

    # Seed an entity with an attribute method.
    #
    # @example
    #   class Plot < Gamefic::Plot
    #     attr_seed :thing, Gamefic::Entity, name: 'thing'
    #   end
    #
    #   plot = Plot.new
    #   plot.thing #=> #<Gamefic::Entity a thing>
    #
    # @param klass [Class<Gamefic::Entity>]
    def attr_seed name, klass, **opts
      @count ||= 0
      seed do
        instance_variable_set("@#{name}", make(klass, **opts))
        self.class.define_method(name) { instance_variable_get("@#{name}") }
      end
      Proxy::Agent.new(@count.tap { @count += 1 })
    end

    if RUBY_ENGINE == 'opal'
      # :nocov:
      def method_missing method, *args, &block
        return super unless respond_to_missing?(method)

        script { send(method, *args, &block) }
      end
      # :nocov:
    else
      def method_missing method, *args, **kwargs, &block
        return super unless respond_to_missing?(method)

        script { send(method, *args, **kwargs, &block) }
      end
    end

    def respond_to_missing?(method, _with_private = false)
      [Scriptable::Actions, Scriptable::Events, Scriptable::Scenes].flat_map(&:public_instance_methods)
                                                                   .include?(method)
    end

    # Create an anonymous module that includes the features of a Scriptable
    # module but does not include its scripts.
    #
    # This can be useful when you need access to the Scriptable's constants and
    # instance methods, but you don't want to duplicate its rules.
    #
    # @example
    #   # Plot and Subplot will both include the `info` method, but
    #   # only Plot will implement the `think` action.
    #
    #   module Shared
    #     extend Gamefic::Scriptable
    #
    #     def info
    #       "This method was added by the Shared module."
    #     end
    #
    #     respond :think do |actor|
    #       actor.tell 'You ponder your predicament.'
    #     end
    #   end
    #
    #   class Plot < Gamefic::Plot
    #     include Shared
    #   end
    #
    #   class Subplot < Gamefic::Subplot
    #     include Shared.no_scripts
    #   end
    #
    # @return [Module]
    def no_scripts
      Module.new.tap do |mod|
        append_features(mod)
      end
    end
  end
end
