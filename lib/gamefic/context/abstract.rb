module Gamefic
  module Context
    class Abstract
      def matches
        []
      end

      def self.match *args, **opts
        new(*args, **opts).matches
      end

      def self.precision
        0
      end
    end
  end
end
