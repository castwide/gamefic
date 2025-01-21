# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's siblings and their descendants. Unlike `Family`, the
    # subject's descendants are excluded from results.
    #
    # Descendants need to be `accessible` to be included in the query.
    #
    class Extended < Base
      include Subqueries

      def span(subject)
        Siblings.span(subject).flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end
    end
  end
end
