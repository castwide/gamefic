module Gamefic
  module Query
    class Itself < Base
      def context_from(subject)
        [subject]
      end

      def magnification
        4
      end
    end
  end
end
