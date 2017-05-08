module Gamefic
  module Query
    class Children < Base
      def context_from(subject)
        subject.children
      end

      def magnification
        3
      end
    end
  end
end
