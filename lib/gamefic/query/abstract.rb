# frozen_string_literal: true

module Gamefic
  module Query
    class Abstract < General
      def span subject
        available_entities(subject).that_are(Describable)
                                   .that_are_not(Entity)
      end
    end
  end
end
