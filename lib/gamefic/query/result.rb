# frozen_string_literal: true

module Gamefic
  module Query
    # The result of a query.
    #
    class Result
      # @return [Entity, Array<Entity>, String, nil]
      attr_reader :match

      # @return [String]
      attr_reader :remainder

      attr_reader :strictness

      def initialize match, remainder, strictness = 0
        @match = match
        @remainder = remainder
        @strictness = strictness
      end
    end
  end
end
