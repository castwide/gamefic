# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's ascendants, descendants, siblings, and siblings'
    # descendants.
    #
    # Entities other than the subject's parent and immediate children need to
    # be `accessible` to be included in the query.
    #
    class Family < Base
      include Subqueries

      def span(subject)
        Ascendants.span(subject) + Descendants.span(subject) + match_sibling_branches(subject)
      end

      private

      def match_sibling_branches(subject)
        Siblings.span(subject).flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end
    end
  end
end
