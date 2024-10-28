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

      # @param scene [Class<Scene::Base>, Symbol]
      def initialize actor, key, narrative, **context
        @actor = actor
        @key = key
        @narrative = narrative
        @context = context
      end

      def start
        @scene ||= new_scene
        props.output.last_input = actor.last_cue&.props&.input
        props.output.last_prompt = actor.last_cue&.props&.prompt
        scene.start
        actor.rotate_cue
      end

      def props
        # @todo Add default when scene is not set?
        scene&.props
      end

      def finish
        scene.play_and_finish
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

      private

      attr_reader :scene

      def new_scene
        narrative.prepare(key, actor, nil, **context) ||
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
