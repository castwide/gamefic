# frozen_string_literal: true

module Gamefic
  module Scripting
    include Scriptable
    include Delegatable::Queries
    # @!parse
    #   include Delegatable::Actions
    #   include Delegatable::Events
    #   include Delegatable::Scenes

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
