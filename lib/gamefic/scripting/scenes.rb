module Gamefic
  module Scripting
    module Scenes
      extend Scriptable

      bind def default_scene
        self.class.default_scene
      end

      bind def default_conclusion
        self.class.default_conclusion
      end

      def introductions
        find_and_bind(:introductions)
      end

      def named_scenes
        {}.merge(*included_scripts.flat_map(&:named_scenes))
      end

      def prepare name_or_class, actor, props, **context
        scene_classes_map[name_or_class]&.new(actor, props, **context).tap do |scene|
          scene&.rename(name_or_class.to_s) if name_or_class.is_a?(Symbol)
        end
      end

      def scenes
        self.class.scenes
      end

      private

      def scene_definitions
        included_scripts.flat_map(&:scene_definitions)
      end

      def scene_classes_map
        {}.merge(*included_scripts.flat_map(&:scene_classes_map))
      end

      def find_and_bind(symbol)
        included_scripts.reverse.flat_map { |script| script.send(symbol) }
                        .map { |blk| Binding.new(self, blk) }
      end
    end
  end
end
