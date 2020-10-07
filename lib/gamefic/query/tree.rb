module Gamefic
  module Query
    # Query to retrieve all of the subject's ancestors, siblings, and descendants.
    #
    class Tree < Family
      def context_from(subject)
        result = super
        parent = subject.parent
        until parent.nil?
          result.unshift parent
          parent = parent.parent
        end
        result
      end
    end
  end
end
