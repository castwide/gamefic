module Gamefic
  module World
    class Scenebook
      # Block a scene in the scenebook.
      #
      # @raise [NameError] if a scene with the given name already exists
      #
      # @param name [Symbol]
      # @param rig [Class<Scene::Rig::Base>]
      # @param type [String, nil]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @param block [Proc]
      # @return [Scene]
      def block name, rig: Scene::Rig::Base, type: nil, on_start: nil, on_finish: nil, &block
        add Scene.new(name, rig: rig, type: type, on_start: on_start, on_finish: on_finish, &block)
      end

      # Add a scene to the scenebook.
      #
      # @raise [NameError] if a scene with the given name already exists
      #
      # @param [Scene]
      # @return [Scene]
      def add scene
        raise NameError, "A scene named `#{name}` already exists" if scene_map.key?(scene.name)

        scene_map[scene.name] = scene
      end

      # @param name [Symbol]
      # @return [Scene]
      def [](name)
        scene_map[name]
      end

      # @param name [Symbol]
      def scene?(name)
        scene_map.key?(name)
      end

      # @return [Array<Symbol>]
      def names
        scene_map.names
      end

      # @return [Array<Scene>]
      def scenes
        scene_map.values
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
