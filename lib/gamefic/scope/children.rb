# frozen_string_literal: true

module Gamefic
  module Scope
    # The Children scope returns an entity's children and all accessible
    # descendants.
    #
    class Children < Base
      def matches
        context.children.flat_map do |c|
          [c] + subquery_accessible(c)
        end
      end
    end
  end
end
