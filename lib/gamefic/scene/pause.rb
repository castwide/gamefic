# frozen_string_literal: true

module Gamefic
  module Scene
    # Pause a scene. This rig simply runs on_start and waits for user input
    # before proceeding to on_finish. The user input itself is ignored by
    # default.
    #
    class Pause < Base
      use_props_class Props::Pause

      def self.type
        'Pause'
      end
    end
  end
end
