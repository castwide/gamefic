# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's children and accessible grandchildren.
    #
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
