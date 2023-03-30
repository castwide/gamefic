# frozen_string_literal: true

module Gamefic
  module Scene
    module Type
      class Activity
        def finish actor
          super
          actor.perform props.input&.strip
        end
      end
    end
  end
end
