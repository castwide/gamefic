# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that accepts player commands for actors to perform.
    #
    class Activity < Default
      def finish actor, props
        super
        actor.perform props.input
      end
    end
  end
end
