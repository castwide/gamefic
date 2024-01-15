# frozen_string_literal: true

module Gamefic
  module Scene
    class Activity < Default
      def finish? actor, props
        super
        actor.perform props.input
        true
      end
    end
  end
end
