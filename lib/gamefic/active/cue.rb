# frozen_string_literal: true

module Gamefic
  module Active
    # The data that actors use to configure a Take.
    #
    class Cue
      attr_reader :actor, :key, :narrative, :scene

      # @return [Hash]
      attr_reader :context

      # @param scene [Class<Scene::Base>, Symbol]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
        # @todo Memoizing the scene might be unsafe. It can be instantiated
        #   from an anonymous class
        @scene = narrative.prepare(key, actor, **context) ||
                 try_unbound_class ||
                 raise("Failed to cue #{key} in #{narrative}")
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

      private

      def try_unbound_class
        return unless @key.is_a?(Class) && @key <= Scene::Base

        Gamefic.logger.info "Cueing unbound scene #{@key}"
        @key.new(@actor, **@context)
      end
    end
  end
end
