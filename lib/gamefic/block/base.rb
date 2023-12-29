# frozen_string_literal: true

module Gamefic
  module Block
    class Base
      attr_reader :code

      # @param code [Proc]
      def initialize(code)
        @code = code
      end

      # @abstract
      # @param narrative [Narrative]
      def execute(narrative); end
    end
  end
end
