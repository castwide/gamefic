module Gamefic
  module Query
    module Subqueries
      module_function

      # Return an array of the entity's accessible descendants.
      #
      # @param [Entity]
      # @return [Array<Entity>]
      def subquery_accessible(entity)
        entity.accessible.flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end
    end
  end
end
