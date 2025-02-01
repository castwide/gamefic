# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Seeds
      # @return [Array<Proc>]
      def seeds
        @seeds ||= []
      end

      # Set methods and procs that get executed when a narrative gets initialized.
      #
      # @example
      #   class Example < Gamefic::Plot
      #     attr_reader :thing
      #
      #     seed do
      #       @thing = make Entity, name: 'thing'
      #     end
      #   end
      #
      def seed *methods, &block
        seeds.push(proc { methods.flatten.each { |method| send(method) } }) unless methods.empty?
        seeds.push block if block
      end

      # Construct an entity.
      #
      # This method adds an instance method for the entity and a class method to
      # reference it with a proxy.
      #
      # @param name [Symbol, String] The method name for the entity
      # @param klass [Class<Gamefic::Entity>]
      # @return [void]
      def construct name, klass, **opts
        ivname = "@#{name}"
        define_method(name) do
          return instance_variable_get(ivname) if instance_variable_defined?(ivname)

          instance_variable_set(ivname, make(klass, **unproxy(opts)))
        end
        seed { send(name) }
        define_singleton_method(name) { Proxy::Attr.new(name) }
      end
      alias attr_make construct
      alias attr_seed construct

      # Add an entity to be seeded when the narrative gets instantiated.
      #
      # @param klass [Class<Gamefic::Entity>]
      # @return [void]
      def make klass, **opts
        seed { make(klass, **unproxy(opts)) }
      end
      alias make_seed make
      alias seed_make make
    end

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

    # Lazy pick an entity or raise an error.
    #
    # @note The class method version of `pick!` returns a proxy, so the error
    #   won't get raised until it gets unproxied in an instance.
    #
    def pick! *args
      Proxy::PickEx.new(*args)
    end
    alias lazy_pick! pick!
  end
end
