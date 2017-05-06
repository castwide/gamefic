module Gamefic
  module Query
    class Parent < Base
      def context_from(subject)
        subject.parent.nil? ? [] : [subject.parent]
      end

      def breadth
        1
      end
    end
  end
end
