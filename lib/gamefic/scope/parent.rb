module Gamefic
  module Scope
    class Parent < Base
      # The Parent scope returns the entity's parent.
      #
      def matches
        [context.parent].compact
      end

      def self.precision
        1000
      end
    end
  end
end
