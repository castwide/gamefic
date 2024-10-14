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
    autoload :Hooks,       'gamefic/scriptable/hooks'
    autoload :Queries,     'gamefic/scriptable/queries'
    autoload :Responses,   'gamefic/scriptable/responses'
    autoload :Scenes,      'gamefic/scriptable/scenes'
    autoload :Seeds,       'gamefic/scriptable/seeds'
    autoload :Syntaxes,    'gamefic/scriptable/syntaxes'
    autoload :PlotProxies, 'gamefic/scriptable/plot_proxies'

    include Hooks
    include Queries
    include Responses
    include Scenes
    include Seeds

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
      Gamefic.logger.warn "The `script` method is deprecated. Use class-level script methods instead."
      instance_exec(&block)
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
    # def seed &block
    #   blocks.push Block.new(:seed, block)
    # end

    def included_scripts
      included_modules.that_are(Scriptable).uniq
    end

    # Lazy make an entity.
    #
    # @example
    #   make Gamefic::Entity, name: 'thing'
    #
    # @param klass [Class<Gamefic::Entity>]
    # @return [Proxy]
    def make klass, **opts
      seed { make(klass, **opts) }
      Proxy::Pick.new(klass, opts[:name], raise: true)
    end
    alias make_seed make

    # Seed an entity with an attribute method.
    #
    # The entity will also be memoized with an instance variable.
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
    def bind_make name, klass, **opts
      ivname = "@#{name}"
      define_method(name) do
        return instance_variable_get(ivname) if instance_variable_defined?(ivname)

        instance_variable_set(ivname, make(klass, **opts))
      end
      define_singleton_method(name) { Proxy::Attr.new(name) }
      bind name
      seed { send name }
      Proxy::Attr.new(name)
    end
    alias attr_make bind_make
    alias attr_seed bind_make

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

    def bind *methods
      bound_methods.merge methods
    end

    def bound_methods
      @bound_methods ||= Set.new
    end
  end
end
