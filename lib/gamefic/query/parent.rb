# frozen_string_literal: true

module Gamefic
  module Query
    # Query the subject's parent.
    #
    class Parent < Base
      def span(subject)
        [subject.parent].compact
      end
    end
  end
end
