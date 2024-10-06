module Gamefic
  module Query
    module Subqueries
      module_function

      # Return an array of the entity's accessible descendants.
      #
      # @param [Entity]
      # @return [Array<Entity>]
      def subquery_accessible entity
        return [] unless entity&.accessible?

        entity.children.flat_map do |c|
          [c] + subquery_accessible(c)
        end
      end
    end
  end
end