module Gamefic
  module Scope
    class Parent < Base
      def matches
        [context.parent].compact
      end
    end
  end
end
