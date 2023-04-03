# frozen_string_literal: true

module Gamefic
  module Rig
    class Activity < Default
      def finish actor
        super
        actor.perform props.input
      end
    end
  end
end
