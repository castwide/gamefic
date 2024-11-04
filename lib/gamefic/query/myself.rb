# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject itself.
    #
    class Myself < Base
      def span(subject)
        [subject]
      end
    end
  end
end
