module Gamefic
  module Scope
    class Parent < Base
      def matches
        [context.parent]
      end
    end
  end
end
