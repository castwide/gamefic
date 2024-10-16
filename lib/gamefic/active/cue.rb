# frozen_string_literal: true

module Gamefic
  module Active
    # The data that actors use to configure a Take.
    #
    class Cue
      attr_reader :actor, :key, :narrative, :props

      # @return [Hash]
      attr_reader :context

      # @param scene [Class<Scene::Base>, Symbol]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
      end

      def start
        scene.start
      end

      def scene
        prepare_scene.tap { |scene| @props = scene.props }
      end

      def finish
        scene.tap { |scene| scene.finish && scene.run_finish_blocks }
      end

      def to_s
        scene.to_s
      end

      private

      def prepare_scene
        narrative.prepare(key, actor, props, **context) ||
        try_unbound_class ||
        raise("Failed to cue #{key.inspect} in #{narrative}")
      end

      def try_unbound_class
        return unless @key.is_a?(Class) && @key <= Scene::Base

        Gamefic.logger.info "Cueing unbound scene #{@key}"
        @key.new(@actor, props, **@context)
      end
    end
  end
end
