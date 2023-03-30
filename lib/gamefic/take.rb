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
      @type = scene.type.new
    end

    def start
      @type.start @actor
      return if @type.cancelled?
      @scene.start_block&.call(@actor, @type.props)
    end

    def finish
      return if @type.cancelled?
      @type.finish @actor
      return if @type.cancelled?
      @scene.finish_block&.call(@actor, @type.props)
    end
  end
end
