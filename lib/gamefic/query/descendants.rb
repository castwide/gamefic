module Gamefic
  module Query
    class Descendants < Children
      def context_from(subject)
        result = []
        children = super
        result.concat children
        children.each { |c|
          result.concat subquery_neighborly(c)
        }
        result
      end

      def breadth
        3
      end
    end
  end
end
