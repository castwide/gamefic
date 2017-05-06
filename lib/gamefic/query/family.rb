module Gamefic
  module Query
    class Family < Base
      def context_from(subject)
        result = []
        top = subject.parent
        unless top.nil?
          until top.parent.nil?
            top = top.parent
          end
          result.concat subquery_neighborly(top)
        end
        result - [subject]
      end

      def breadth
        4
      end
    end
  end
end
