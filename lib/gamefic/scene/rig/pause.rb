# frozen_string_literal: true

module Gamefic
  class Scene
    module Rig
      class Pause < Base
        def start _actor
          props.prompt = 'Press enter to continue...'
        end

        def finish
          actor.cue :activity # This can be overridden with Scene#on_finish
        end
      end
    end
  end
end
