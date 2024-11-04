# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's children.
    #
    class Children < Base
      include Subqueries

      def span(subject)
        subject.children
      end
    end
  end
end
