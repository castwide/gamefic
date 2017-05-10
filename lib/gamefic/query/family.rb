module Gamefic
  module Query
    class Family < Base
      def context_from(subject)
        result = []
        top = subject.parent
        unless top.nil?
          #until top.parent.nil?
          #  top = top.parent
          #end
          result.concat subquery_accessible(top)
        end
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
