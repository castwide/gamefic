module Gamefic
  module Query
    class Parent < Base
      def context_from(subject)
        subject.parent.nil? ? [] : [subject.parent]
      end

      def magnification
        4
      end
    end
  end
end
