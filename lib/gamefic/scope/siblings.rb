# frozen_string_literal: true

module Gamefic
  module Scope
    # A query scope that matches the entity's siblings, i.e., the other
    # entities that share its parent.
    #
    class Siblings < Base
      def matches
        context.parent.children - [context]
      end
    end
  end
end
