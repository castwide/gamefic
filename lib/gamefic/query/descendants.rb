# frozen_string_literal: true

module Gamefic
  module Query
    class Descendants < Base
      include Subqueries

      def span subject
        subject.children.flat_map do |child|
          [child] + subquery_accessible(child)
        end
      end
    end
  end
end
