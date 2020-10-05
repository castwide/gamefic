module Gamefic
  module Query
    class Descendants < Children
      def context_from(subject)
        result = []
        children = super
        result.concat children
        children.each do |c|
          result.concat subquery_accessible(c)
        end
        result
      end
    end
  end
end
