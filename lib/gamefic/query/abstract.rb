# frozen_string_literal: true

module Gamefic
  module Query
    # Query pseudo-entities that include `Describable` but not `Node`.
    #
    class Abstract < Global
      def span(subject)
        super.that_are_not(Node)
             .that_are(Describable)
      end

      def precision
        @precision ||= super - 2000
      end
    end
  end
end
