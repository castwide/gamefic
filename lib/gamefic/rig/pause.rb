# frozen_string_literal: true

module Gamefic
  module Rig
    class Pause < Default
      def start _actor
        super
        props.prompt = 'Press enter to continue...'
      end
    end
  end
end
