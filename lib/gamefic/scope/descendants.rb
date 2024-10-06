# frozen_string_literal: true

module Gamefic
  module Scope
    # The Descendants scope returns an entity's children and accessible
    # descendants.
    #
    class Descendants < Base
      def matches
        context.children.flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end
    end
  end
end
