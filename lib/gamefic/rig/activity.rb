# frozen_string_literal: true

module Gamefic
  module Rig
    # A rig for processing user input as a command at the end of a scene.
    #
    class Activity < Default
      def finish actor
        super
        actor.perform props.input
      end
    end
  end
end
