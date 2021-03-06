module Gamefic
  module Query
    class Siblings < Base
      def context_from(subject)
        result = []
        unless subject.parent.nil?
          result.concat(subject.parent.children - [subject])
        end
        result
      end
    end
  end
end
