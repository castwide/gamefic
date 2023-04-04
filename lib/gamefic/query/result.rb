module Gamefic
  module Query
    class Result
      attr_reader :match

      attr_reader :remainder

      def initialize match, remainder
        @match = match
        @remainder = remainder
      end
    end
  end
end
