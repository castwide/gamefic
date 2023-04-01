# frozen_string_literal: true

module Gamefic
  class Scene
    module Rig
      class Pause < Base
        def start _actor
          props.prompt = 'Press enter to continue...'
        end
      end
    end
  end
end
