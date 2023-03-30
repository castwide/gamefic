module Gamefic
  module World
    class Scenebook
      def initialize
        block :activity, Ac
      end

      def block name, scene_type = Scene::Type::Base, &block
        raise ArgumentError, "A scene named `#{name}` is already blocked" if scene_map.key?(name)
        scene_map[name] = scene_class.new(name, scene_type, &block)
      end

      # @todo Should this raise an error?
      # @param name [Symbol]
      # @return [Scene]
      def read name
        scene_map[name]
      end

      def freeze
        super
        # @todo Freeze appropriately
      end

      private

      def scene_map
        @scene_map ||= {}
      end
    end
  end
end
