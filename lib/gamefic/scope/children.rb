module Gamefic
  module Scope
    class Children < Base
      def matches
        context.children
      end
    end
  end
end
