module Gamefic
  module Scope
    class Siblings < Base
      # The Siblings scope returns the entity's siblings, i.e., all other
      # entities that share its parent.
      #
      def matches
        context.parent.children - [context]
      end
    end
  end
end
