module Gamefic
  module Scope
    class Siblings < Base
      def matches
        context.parent.children - [c]
      end

      private

      # Return an array of the entity's accessible descendants.
      #
      # @param [Entity]
      # @return [Array<Entity>]
      def subquery_accessible entity, force = false
        return [] if entity.nil?

        result = []
        if force || entity.accessible?
          entity.children.each do |c|
            result.push c
            result.concat subquery_accessible(c)
          end
        end
        result
      end
    end
  end
end
