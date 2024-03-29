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

      def initialize match, remainder
        @match = match
        @remainder = remainder
      end
    end
  end
end
