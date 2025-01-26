# frozen_string_literal: true

module Gamefic
  module Active
    # The object that actors use to perform a scene.
    #
    class Cue
      # @return [Actor]
      attr_reader :actor

      # @return [Class<Scene::Base>, Symbol]
      attr_reader :key

      # @return [Narrative]
      attr_reader :narrative

      # @return [Hash]
      attr_reader :context

      # @return [Props::Default, nil]
      attr_reader :props

      # @param actor [Actor]
      # @param key [Class<Scene::Base>, Symbol]
      # @param narrative [Narrative]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
      end

      # @return [void]
      def start
        @props = scene.start
        prepare_output
        actor.rotate_cue
      end

      # @return [void]
      def finish
        props&.enter(actor.queue.shift&.strip)
        scene.finish
      end

      # @return [Props::Output]
      def output
        props&.output.clone.freeze || Props::Output::EMPTY
      end

      # @return [Cue]
      def restart
        Cue.new(actor, key, narrative, **context)
      end

      def type
        scene&.type
      end

      def to_s
        scene.to_s
      end

      # @return [void]
      def prepare
        props.output.merge!({
                              scene: scene.to_hash,
                              prompt: props.prompt,
                              messages: actor.flush,
                              queue: actor.queue
                            })
        actor.narratives.player_output_blocks.each { |block| block.call actor, props.output }
      end

      # @return [Scene::Base]
      def scene
        # @note This method always returns a new instance. Scenes identified
        #   by symbolic keys can be instances of anonymous classes that cannot
        #   be serialized, so memoizing them breaks snapshots.
        narrative&.prepare(key, actor, props, **context) ||
          try_unblocked_class ||
          raise("Failed to cue #{key.inspect} in #{narrative.inspect}")
      end

      private

      # @return [Scene::Base]
      def try_unblocked_class
        return unless key.is_a?(Class) && key <= Scene::Base

        Gamefic.logger.warn "Cueing scene #{key} without narrative" unless narrative
        key.new(actor, narrative, props, **context)
      end

      # @return [void]
      def prepare_output
        props.output.last_input = actor.last_cue&.props&.input
        props.output.last_prompt = actor.last_cue&.props&.prompt
      end
    end
  end
end
