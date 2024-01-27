# frozen_string_literal: true

module Gamefic
  module Active
    # The data that actors use to configure a Take.
    #
    class Cue
      # @return [Symbol]
      attr_reader :scene

      # @return [Hash]
      attr_reader :context

      # @param scene [Symbol]
      def initialize scene, **context
        @scene = scene
        @context = context
      end

      def to_s
        scene.to_s
      end
    end
  end
end
