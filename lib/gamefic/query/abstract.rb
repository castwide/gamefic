# frozen_string_literal: true

module Gamefic
  module Query
    class Abstract < Global
      def span subject
        super.that_are_not(Node)
             .that_are(Describable)
      end

      def precision
        @precision ||= super - 1000
      end
    end
  end
end
