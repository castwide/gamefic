# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's children.
    #
    class Children < Base
      include Subqueries

      def span subject
        subject.children.flat_map do |c|
          [c] + subquery_accessible(c)
        end
      end
    end
  end
end
