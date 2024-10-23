# frozen_string_literal: true

module Gamefic
  module Active
    # The data that actors use to configure a Take.
    #
    class Cue
      attr_reader :actor, :key, :narrative

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
        @scene ||= narrative.prepare(key, actor, nil, **context) ||
                   try_unbound_class ||
                   raise("Failed to cue #{key.inspect} in #{narrative}")
        props.output.last_input = actor.last_cue&.props&.input
        props.output.last_prompt = actor.last_cue&.props&.prompt
        scene.start
      end

      def props
        # @todo Add default when scene is not set?
        scene&.props
      end

      def finish
        scene.prepare_and_finish
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

      def prepare(blocks)
        props.output[:scene] = scene.to_hash
        props.output[:prompt] = props.prompt
        props.output.merge!({
                              messages: actor.messages,
                              queue: actor.queue
                            })
        blocks.each { |block| block.call actor, props.output }
      end

      private

      attr_reader :scene

      def try_unbound_class
        return unless @key.is_a?(Class) && @key <= Scene::Base

        Gamefic.logger.info "Cueing unbound scene #{@key}"
        @key.new(@actor, props, **@context)
      end
    end
  end
end
