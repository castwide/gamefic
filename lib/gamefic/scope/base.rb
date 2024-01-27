# frozen_string_literal: true

module Gamefic
  module Scope
    # The base class for a Scoped query's scope.
    #
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

      private

      # Return an array of the entity's accessible descendants.
      #
      # @param [Entity]
      # @return [Array<Entity>]
      def subquery_accessible entity
        return [] unless entity&.accessible?

        entity.children.flat_map do |c|
          [c] + subquery_accessible(c)
        end
      end
    end
  end
end
