# frozen_string_literal: true

module Gamefic
  module Rig
    # Pause a scene. This rig simply runs on_start and waits for user input
    # before proceeding to on_finish. The user input itself is ignored.
    #
    class Pause < Default
      def start _actor
        super
        props.prompt = 'Press enter to continue...'
      end
    end
  end
end
