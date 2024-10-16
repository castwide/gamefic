# frozen_string_literal: true

module Gamefic
  class Plot
    class Take
      attr_reader :actor, :default_scene, :cue

      def initialize actor, default_scene
        @actor = actor
        @default_scene = default_scene
      end

      def start
        @cue = actor.next_cue || actor.cue(default_scene)
        cue.start
        actor.cue_started
      end

      def finish
        cue&.finish
        actor.cue_finished
      end
    end
  end
end
