module Gamefic
  module Props
    class Pause < Default
      def prompt
        @prompt ||= 'Press enter to continue...'
      end
    end
  end
end
