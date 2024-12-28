module Gamefic
  module Scripting
    module Scenes
      # @return [Scene::Base]
      def default_scene
        self.class.default_scene
      end

      # @return [Scene::Conclusion]
      def default_conclusion
        self.class.default_conclusion
      end

      # @return [Array<Binding>]
      def introductions
        included_scripts.reverse
                        .flat_map(&:introductions)
                        .map { |blk| Binding.new(self, blk) }
      end

      # @return [Hash]
      def named_scenes
        {}.merge(*included_scripts.flat_map(&:named_scenes))
      end

      # Prepare a scene to be executed. Scenes can be accessed by their class
      # or by a symbolic name if one has been defined in this narrative.
      #
      # @param name_or_class [Symbol, Class<Scene::Base>]
      # @param actor [Actor]
      # @param props [Props::Default]
      # @return [Scene::Base]
      def prepare name_or_class, actor, props, **context
        scene_classes_map[name_or_class]&.new(actor, self, props, **context).tap do |scene|
          scene&.rename(name_or_class.to_s) if name_or_class.is_a?(Symbol)
        end
      end

      # @return [Array<Scene::Base>]
      def scenes
        self.class.scenes
      end

      # @param name_or_class [Symbol, Class<Scene::Base>]
      # @return [Scene::Base]
      def scene_class(name_or_class)
        scene_classes_map[name_or_class]
      end

      private

      def scene_classes_map
        {}.merge(*included_scripts.flat_map(&:scene_classes_map))
      end
    end
  end
end
