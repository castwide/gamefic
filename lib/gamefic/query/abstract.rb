# frozen_string_literal: true

module Gamefic
  module Query
    class Abstract < General
      def span subject
        super.that_are_not(Node)
             .that_are(Describable)
      end
    end
  end
end
