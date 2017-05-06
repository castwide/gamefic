module Gamefic
  module Query
    class Itself < Base
      def context_from(subject)
        [subject]
      end

      def breadth
        1
      end
    end
  end
end
