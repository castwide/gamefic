# frozen_string_literal: true

module Gamefic
  module Query
    class Abstract < Global
      def span subject
        super.that_are_not(Node)
             .that_are(Describable)
      end
    end
  end
end
