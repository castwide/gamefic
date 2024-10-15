# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Entities
      # @todo A lot of this stuff can probably be eliminated.

      # Lazy make an entity.
      #
      # @example
      #   make Gamefic::Entity, name: 'thing'
      #
      # @param klass [Class<Gamefic::Entity>]
      # @return [Proxy]
      def make klass, **opts
        Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`make` is deprecated. Use `construct` or `seed` instead."
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
        Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`bind_make` is deprecated. Use `construct` instead."
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

      # Lazy pick an entity or raise an error
      #
      def pick! *args
        Proxy::Pick.new(*args)
      end
      alias lazy_pick! pick
      alias _pick! pick
    end
  end
end
