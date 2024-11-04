# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's siblings (i.e., entities with the same parent).
    class Siblings < Base
      def span(subject)
        (subject.parent&.children || []) - [subject]
      end
    end
  end
end
