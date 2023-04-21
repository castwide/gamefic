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
      @rig.start @actor
      return if @rig.cancelled?

      @scene.start_blocks.each { |blk| blk&.call(@actor, @rig.props) }
      @rig.ready
    end

    def finish
      return if @rig.cancelled?

      @rig.finish @actor
      return if @rig.cancelled?

      @scene.finish_blocks.each { |blk| blk&.call(@actor, @rig.props) }
      @actor.output.replace(
        {
          last_prompt: @rig.props.prompt,
          last_input: @rig.props.input
        }
      )
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
