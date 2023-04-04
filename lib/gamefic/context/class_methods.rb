module Gamefic
  module Context
    module ClassMethods
      def match *args, **opts
        new(*args, **opts).matches
      end

      def precision
        0
      end
    end
  end
end
