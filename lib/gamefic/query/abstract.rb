module Gamefic
  module Query
    class Abstract
      def matches
        []
      end

      def self.match *args, **opts
        new(*args, **opts).matches
      end

      def self.relative?
        false
      end

      def self.precision
        0
      end
    end
  end
end
