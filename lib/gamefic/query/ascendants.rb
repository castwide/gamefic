# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's parent and accessible grandparents.
    #
    class Ascendants < Base
      include Subqueries

      def span(subject)
        [subject.parent].tap { |result| result.push result.last.parent while result.last&.parent&.accessible&.include?(result.last) }
                        .compact
      end
    end
  end
end
