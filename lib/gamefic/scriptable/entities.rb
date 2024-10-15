# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Entities
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

      # Lazy pick an entity or raise an error
      #
      def pick! *args
        Proxy::Pick.new(*args)
      end
      alias lazy_pick! pick
    end
  end
end
