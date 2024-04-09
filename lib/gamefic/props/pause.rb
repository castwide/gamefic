# frozen_string_literal: true

module Gamefic
  module Props
    # Props for Pause scenes.
    #
    class Pause < Default
      def prompt
        @prompt ||= 'Press enter to continue...'
      end
    end
  end
end
