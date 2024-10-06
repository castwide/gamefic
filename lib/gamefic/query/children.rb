# frozen_string_literal: true

module Gamefic
  module Query
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
