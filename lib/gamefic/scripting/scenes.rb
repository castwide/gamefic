module Gamefic
  module Scripting
    module Scenes
      def default_scene
        self.class.default_scene
      end

      def default_conclusion
        self.class.default_conclusion
      end

      def introductions
        find_and_bind(:introductions)
      end

      def named_scenes
        {}.merge(*included_scripts.flat_map(&:named_scenes))
          .merge(self.class.named_scenes)
      end

      def prepare name_or_class, actor, **context
        scene_classes_map[name_or_class]&.new(actor, **context)
      end

      private

      def scene_definitions
        included_scripts.flat_map(&:scene_definitions)
                        .concat(self.class.scene_definitions)
      end

      def scene_classes_map
        {}.merge(*included_scripts.flat_map(&:scene_classes_map))
          .merge(self.class.scene_classes_map)
      end

      def find_and_bind(symbol)
        included_scripts.flat_map { |script| script.send(symbol) }
                        .concat(self.class.send(symbol))
                        .map { |blk| Binding.new(self, blk) }
      end
    end
  end
end
