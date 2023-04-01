# frozen_string_literal: true

module Gamefic
  # The combination of an actor and a scene to be performed in a plot
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
      @rig = scene.rig.new(**context)
    end

    def start
      @rig.start @actor
      return if @rig.cancelled?

      @scene.start_blocks.each { |blk| blk&.call(@actor, @rig.props) }
    end

    def finish
      return if @rig.cancelled?

      @rig.finish @actor
      return if @rig.cancelled?

      @scene.finish_blocks.each { |blk| blk&.call(@actor, @rig.props) }
    end

    def cancelled?
      @rig.cancelled?
    end
  end
end
