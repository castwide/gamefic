# frozen_string_literal: true

module Gamefic
  module Query
    class Family < Base
      include Subqueries

      def span subject
        match_ascendants(subject) + match_descendants(subject) + match_siblings(subject)
      end

      private

      def match_ascendants context
        [].tap do |result|
          here = context.parent
          while here
            result.push here
            here = here.parent
          end
        end
      end

      def match_descendants context
        context.children.flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end

      def match_siblings context
        return [] unless context.parent

        context.parent
               .children
               .that_are_not(context)
               .flat_map do |child|
                 [child] + subquery_accessible(child)
               end
      end
    end
  end
end
