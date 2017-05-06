module Gamefic
  module Query
    class Neighbors < Siblings
      def context_from(subject)
        result = []
        siblings = super
        result.concat siblings
        siblings.each { |s|
          result.concat subquery_neighborly(s)
        }
        result
      end

      def significance
        400
      end
    end
  end
end
