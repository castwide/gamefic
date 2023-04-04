module Gamefic
  module Scope
    class Base
      attr_reader :context

      # @param [Gamefic::Entity]
      def initialize context
        @context = context
      end

      # @param [Array<Gamefic::Entity>]
      def matches
        []
      end

      # @param [Gamefic::Entity]
      def self.matches context
        new(context).matches
      end

      def self.precision
        0
      end
    end
  end
end
