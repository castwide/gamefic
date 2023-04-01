module Gamefic
  module Active
    class Cue
      # @return [Scene]
      attr_reader :scene

      # @return [Hash]
      attr_reader :context

      # @param scene [Scene]
      # @param context [Hash]
      def initialize scene, **context
        @scene = scene
        @context = context
      end

      def name
        scene.name
      end
    end
  end
end
