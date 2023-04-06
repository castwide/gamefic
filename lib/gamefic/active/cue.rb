module Gamefic
  module Active
    class Cue
      # @return [Symbol]
      attr_reader :scene

      # @return [Hash]
      attr_reader :context

      # @param scene [Symbol]
      # @param context [Hash]
      def initialize scene, **context
        @scene = scene
        @context = context
      end
    end
  end
end
