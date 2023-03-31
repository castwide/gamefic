# frozen_string_literal: true

module Gamefic
  # The combination of an actor and a scene to be performed in a plot
  #
  class Take
    # @param actor [Gamefic::Active]
    # @param scene [Gamefic::Scene]
    def initialize actor, scene
      @actor = actor
      @scene = scene
      @rig = scene.rig.new
    end

    def start
      @rig.start @actor
      return if @rig.cancelled?

      @scene.start_block&.call(@actor, @rig.props)
    end

    def finish
      return if @rig.cancelled?

      @rig.finish @actor
      return if @rig.cancelled?

      @scene.finish_block&.call(@actor, @rig.props)
    end
  end
end
