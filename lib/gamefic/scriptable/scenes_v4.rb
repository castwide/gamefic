# frozen_string_literal: true

module Gamefic
  module Scriptable
    module ScenesV4
      def block *args, &blk
        if args.first.is_a?(Symbol)
          name, klass = args
          klass ||= Scene::Default
          Gamefic.logger.warn "Scenes with symbol names are deprecated. Use constants (e.g., `#{name.to_s.cap_first} = block(...)`) instead."
          script do
            rulebook.scenes.add klass.hydrate(name, klass, &blk), name
            name
          end
          name
        else
          klass = args.first || Scene::Default
          scene = klass.hydrate(name, self, &blk)
          script { scene.update_narrative self }
          scene
        end
      end
    end
  end
end
