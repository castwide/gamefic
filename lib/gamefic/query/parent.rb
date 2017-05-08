module Gamefic
  module Query
    class Parent < Base
      def context_from(subject)
        subject.parent.nil? ? [] : [subject.parent]
      end
    end
  end
end
