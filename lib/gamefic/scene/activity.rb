# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that accepts player commands for actors to perform.
    #
    class Activity < Base
      def finish
        super
        actor.perform props.input
      end

      def self.type
        'Activity'
      end
    end
  end
end
