module Gamefic
  module Query
    # Query to retrieve the subject's siblings and all accessible descendants.
    #
    class Family < Base
      def context_from(subject)
        result = []
        result.concat subquery_accessible(subject.parent)
        result.delete subject
        subject.children.each { |c|
          result.push c
          result.concat subquery_accessible(c)
        }
        result
      end
    end
  end
end
