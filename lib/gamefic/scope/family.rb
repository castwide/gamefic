module Gamefic
  module Scope
    class Family < Base
      def matches
        result = []
        result.concat subquery_accessible(context.parent)
        result.delete context
        context.children.each { |c|
          result.push c
          result.concat subquery_accessible(c)
        }
        result
      end

      private

      # Return an array of the entity's accessible descendants.
      #
      # @param [Entity]
      # @return [Array<Entity>]
      def subquery_accessible entity
        return [] if entity.nil?

        result = []
        if entity.accessible?
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
