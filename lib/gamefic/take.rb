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
    # @param props [Props::Default]
    # @param context [Hash]
    def initialize actor, scene, props = nil, **context
      @actor = actor
      @scene = scene
      @rig = scene.rig.new(scene, props, **context)
    end

    # @return [Props::Default]
    def start
      buffer = @actor.buffer do
        @rig.start @actor
        scene.run_start_blocks @actor, @rig.props unless @rig.cancelled?
      end
      output[:messages] += buffer
      @rig.ready
      actor.epic.rulebooks.each { |rlbk| rlbk.events.run_player_output_blocks actor, output }
      actor.output.merge! output
      actor.output.merge!({
                            messages: actor.messages + output[:messages],
                            queue: actor.queue
                          })
      @rig.props
    end

    # @return [void]
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

    # @param actor [Active]
    # @param scene [Scene]
    # @param context [Hash]
    def self.start actor, scene, context
      Take.new(actor, scene, **context).start
    end

    # @param actor [Active]
    # @param scene [Scene]
    # @param context [Hash]
    # @param props [Props::Default]
    def self.finish actor, scene, context, props
      Take.new(actor, scene, props, **context).finish
    end
  end
end
