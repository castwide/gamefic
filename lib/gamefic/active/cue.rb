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

      # @param scene [Class<Scene::Base>, Symbol]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
      end

      def start
        @props = scene.start
        prepare_output
        actor.rotate_cue
      end

      def finish
        props&.enter(actor.queue.shift&.strip)
        scene.finish
      end

      def output
        props&.output.clone.freeze || Props::Output::EMPTY
      end

      def restart
        Cue.new(actor, key, narrative, **context)
      end

      def type
        scene&.type
      end

      def to_s
        scene.to_s
      end

      def prepare
        props.output.merge!({
                              scene: scene.to_hash,
                              prompt: props.prompt,
                              messages: actor.messages,
                              queue: actor.queue
                            })
        actor.narratives.player_output_blocks.each { |block| block.call actor, props.output }
      end

      # @return [Scene::Base]
      def scene
        narrative&.prepare(key, actor, props, **context) ||
          try_unblocked_class ||
          raise("Failed to cue #{key.inspect} in #{narrative.inspect}")
      end

      private

      def try_unblocked_class
        return unless key.is_a?(Class) && @key <= Scene::Base

        Gamefic.logger.warn "Cueing scene #{key} without narrative" unless narrative
        key.new(actor, narrative, props, **context)
      end

      def prepare_output
        scene
        props.output.last_input = actor.last_cue&.props&.input
        props.output.last_prompt = actor.last_cue&.props&.prompt
      end
    end
  end
end
