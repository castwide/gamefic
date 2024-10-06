# frozen_string_literal: true

module Gamefic
  module Scope
    # The Family scope returns an entity's ascendants, descendants, siblings,
    # and siblings' descendants.
    #
    class Family < Base
      def matches
        match_ascendants + match_descendants + match_siblings
      end

      private

      def match_ascendants
        [].tap do |result|
          here = context.parent
          while here
            result.push here
            here = here.parent
          end
        end
      end

      def match_descendants
        context.children.flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end

      def match_siblings
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
