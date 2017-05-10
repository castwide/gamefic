module Gamefic
  module Query
    class Children < Base
      def context_from(subject)
        subject.children
      end
    end
  end
end
