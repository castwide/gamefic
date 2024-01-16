# frozen_string_literal: true

module Gamefic
  # The combination of an actor and a scene to be performed in a plot turn.
  #
  class Take
    # @param actor [Active]
    # @param scene [Scene]
    # @param context [Hash]
    def initialize actor, scene, **context
      @actor = actor
      @scene = scene
      @props = @scene.new_props(**context)
    end

    # @return [self]
    def start
      @scene.run_start_blocks @actor, @props
      @scene.start @actor, @props
      self
    end

    # @return [void]
    def finish
      @actor.flush
      return unless @scene.finish?(@actor, @props)

      @scene.run_finish_blocks @actor, @props
    end

    # @param actor [Active]
    # @param scene [Scene]
    # @param context [Hash]
    # @return [self]
    def self.start actor, scene, **context
      Take.new(actor, scene, **context).start
    end
  end
end
