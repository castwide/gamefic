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
    autoload :Actions,     'gamefic/scriptable/actions'
    autoload :Entities,    'gamefic/scriptable/entities'
    autoload :Events,      'gamefic/scriptable/events'
    autoload :Queries,     'gamefic/scriptable/queries'
    autoload :Proxies,     'gamefic/scriptable/proxies'
    autoload :Scenes,      'gamefic/scriptable/scenes'
    autoload :PlotProxies, 'gamefic/scriptable/plot_proxies'

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
    # @return [Proxy]
    def make_seed klass, **opts
      seed { make(klass, **opts) }
      Proxy::Pick.new(klass, opts[:name], raise: true)
    end
    alias make make_seed

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
    # @param name [Symbol] The attribute name
    # @param klass [Class<Gamefic::Entity>]
    # @return [Proxy]
    def attr_seed name, klass, **opts
      # Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`attr_seed` is deprecated."
      ivname = "@#{name}"
      define_method(name) do
        return instance_variable_get(ivname) if instance_variable_defined?(ivname)

        instance_variable_set(ivname, make(klass, **opts))
      end
      seed { send name }
      Proxy.new(:attr, name)
    end

    # @param symbol [Symbol]
    # @return [Proxy]
    def proxy symbol
      Logging.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`proxy` is deprecated. Use `pick` or `pick!` instead."
      if symbol.to_s.start_with?('@')
        Proxy.new(:ivar, symbol)
      else
        Proxy.new(:attr, symbol)
      end
    end

    # Lazy reference an entity by its instance variable.
    #
    # @example
    #   lazy_ivar(:@variable)
    #
    # @param key [Symbol]
    # @return [Proxy]
    def lazy_ivar key
      Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`lazy_ivar` is deprecated. Use `pick` or `pick!` instead."
      Proxy.new(:ivar, key)
    end
    alias _ivar lazy_ivar

    # Lazy reference an entity by its attribute or method.
    #
    # @example
    #   lazy_attr(:method)
    #
    # @param key [Symbol]
    # @return [Proxy]
    def lazy_attr key
      Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`lazy_attr` is deprecated. Use `pick` or `pick!` instead."
      Proxy.new(:attr, key)
    end
    alias _attr lazy_attr

    # Lazy pick an entity.
    #
    # @example
    #   pick('the red box')
    #
    # @param args [Array]
    # @return [Proxy]
    def pick *args
      Proxy::Pick.new(*args)
    end
    alias lazy_pick pick
    alias _pick pick

    # Lazy pick an entity or raise
    #
    def pick! *args
      Proxy::Pick.new(*args)
    end
    alias lazy_pick! pick
    alias _pick! pick

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
    # @deprecated Removing script blocks is no longer necessary. This method
    #   will simply return self until it's removed.
    #
    # @return [Module<self>]
    def no_scripts
      Logging.logger.warn "#{caller.first ? "#{caller.first}: " : ''}Calling `no_scripts` on Scriptable modules is no longer necessary."
      self
    end
  end
end
