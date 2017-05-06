module Gamefic
  module Query
    class Children < Base
      def context_from(subject)
        subject.children
      end

      def breadth
        2
      end
    end
  end
end
