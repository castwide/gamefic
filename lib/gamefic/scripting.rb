# frozen_string_literal: true

module Gamefic
  module Scripting
    include Scriptable
    # @!parse
    #   include Delegatable::Actions
    #   include Delegatable::Events
    #   include Delegatable::Queries
    #   include Delegatable::Scenes

    def attr_seed name, klass, **opts
      seed do
        instance_variable_set("@#{name}", make(klass, **opts))
        self.class.define_method(name) { instance_variable_get("@#{name}") }
      end
      name
    end

    def proxy symbol
      Proxy.new(symbol)
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
      [Delegatable::Actions, Delegatable::Events, Delegatable::Scenes].flat_map(&:public_instance_methods)
                                                                      .include?(method)
    end
  end
end
