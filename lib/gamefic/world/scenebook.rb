module Gamefic
  module World
    class Scenebook
      def initialize
        block :activity, Scene::Activity
      end

      # @param name [Symbol]
      # @param type [Class<SceneType::Base>]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @param block [Proc]
      def block name, scene_type = Scene::Type::Base, on_start: nil, on_finish: nil, &block
        raise ArgumentError, "A scene named `#{name}` is already blocked" if scene_map.key?(name)
        scene_map[name] = Scene.new(name, type: scene_type, on_start: on_start, on_finish: on_finish, &block)
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
