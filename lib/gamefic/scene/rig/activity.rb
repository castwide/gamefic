# frozen_string_literal: true

module Gamefic
  class Scene
    module Rig
      class Activity < Base
        def finish actor
          super
          actor.perform props.input
        end
      end
    end
  end
end