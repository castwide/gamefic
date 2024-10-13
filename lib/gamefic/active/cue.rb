# frozen_string_literal: true

module Gamefic
  module Active
    # The data that actors use to configure a Take.
    #
    class Cue
      attr_reader :actor

      attr_reader :key

      attr_reader :narrative

      attr_reader :scene

      # @return [Hash]
      attr_reader :context

      # @param scene [Class<Scene::Default>, Symbol]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
        @scene = narrative.prepare key, actor, **context
        raise "Failed to cue #{scene} in #{narrative}" unless @scene
      end

      def start
        @scene.start
      end

      def props
        @scene.props
      end

      def finish
        @scene.finish
        @scene.run_finish_blocks
      end

      def to_s
        scene.to_s
      end
    end
  end
end
