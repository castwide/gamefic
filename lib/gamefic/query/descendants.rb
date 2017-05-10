module Gamefic
  module Query
    class Descendants < Children
      def context_from(subject)
        result = []
        children = super
        result.concat children
        children.each { |c|
          result.concat subquery_accessible(c)
        }
        result
      end
    end
  end
end
