# frozen_string_literal: true

module Gamefic
  module Query
    # Query all the entities in the subject's epic.
    #
    # If the subject is not an actor, this query will always return an empty
    # result.
    #
    class Global < Base
      def span(subject)
        return [] unless subject.is_a?(Active)

        subject.narratives.entities
      end

      def precision
        @precision ||= super - 2000
      end
    end
  end
end
