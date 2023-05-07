# frozen_string_literal: true

module Gamefic
  # The combination of an actor and a scene to be performed in a plot turn.
  #
  class Take
    # @return [Active]
    attr_reader :actor

    # @return [Scene]
    attr_reader :scene

    # @param actor [Active]
    # @param scene [Scene]
    # @param context [Hash]
    def initialize actor, scene, **context
      @actor = actor
      @scene = scene
      @rig = scene.rig.new(scene, **context)
    end

    def start
      buffer = @actor.buffer do
        @rig.start @actor
        scene.run_start_blocks @actor, @rig.props unless @rig.cancelled?

      end
      output[:messages] += buffer
      @rig.ready
    end

    def finish
      @actor.flush
      return if @rig.cancelled?

      @rig.finish @actor
      @actor.output.replace(
        {
          last_prompt: @rig.props.prompt,
          last_input: @rig.props.input
        }
      )
      @actor.last_input = @rig.props.input
      return if @rig.cancelled?

      @scene.run_finish_blocks @actor, @rig.props
    end

    def output
      @rig.props.output
    end

    def cancelled?
      @rig.cancelled?
    end

    def conclusion?
      @rig.is_a?(Rig::Conclusion)
    end
  end
end
