# frozen_string_literal: true

module Gamefic
  # The combination of an actor and a scene to be performed in a plot turn.
  #
  class Take
    # @param actor [Active]
    # @param cue [Active::Cue]
    # @param props [Props::Default]
    def initialize actor, cue, props = nil
      @actor = actor
      @scene = actor.epic.select_scene(cue.scene)
      @props = props || @scene.new_props(**cue.context)
    end

    # @return [Props::Default]
    def start
      @actor.output[:scene] = @scene.to_hash
      @scene.run_start_blocks @actor, @props
      @scene.start @actor, @props
      @props
    end

    # @return [void]
    def finish
      @actor.flush
      return unless @scene.finish?(@actor, @props)

      @scene.run_finish_blocks @actor, @props
    end

    # @param actor [Active]
    # @param cue [Active::Cue]
    # @return [Props::Default]
    def self.start actor, cue
      Take.new(actor, cue).start
    end

    # @param actor [Active]
    # @param cue [Active::Cue]
    # @return [void]
    def self.finish actor, cue, props
      Take.new(actor, cue, props).finish
    end
  end
end
