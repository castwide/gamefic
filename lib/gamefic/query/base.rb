# frozen_string_literal: true

module Gamefic
  module Query
    # A base class for entity-based queries that can be applied to responses.
    # Each query represents an attempt to match an argument in a command to a
    # game entity.
    #
    class Base
      # @return [Array<Object>]
      attr_reader :arguments

      # @return [Boolean]
      attr_reader :ambiguous

      # @raise [ArgumentError] if any of the arguments are nil
      #
      # @param arguments [Array<Object>]
      # @param ambiguous [Boolean]
      def initialize *arguments, ambiguous: false
        raise ArgumentError, "nil argument in query" if arguments.any?(&:nil?)

        @arguments = arguments
        @ambiguous = ambiguous
      end

      # @deprecated Queries should only be used to select entities that are
      #   eligible to be response arguments. After a text command is tokenized
      #   into an array of expressions, the composer builds the command that
      #   the dispatcher uses to execute actions. The #accept? method verifies
      #   that the command's arguments match the response's queries.
      #
      # @param subject [Gamefic::Entity]
      # @param token [String]
      # @return [Result]
      def query(subject, token)
        raise "#query not implemented for #{self.class}"
      end

      # Get an array of entities that match the query from the context of the
      # subject.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def select subject
        raise "#select not implemented for #{self.class}"
      end

      def accept?(subject, object)
        available = select(subject)
        if ambiguous?
          object & available == object
        else
          available.include?(object)
        end
      end

      # @return [Integer]
      def precision
        @precision ||= calculate_precision
      end

      def ambiguous?
        @ambiguous
      end

      private

      def calculate_precision
        @arguments.sum(@ambiguous ? -1000 : 0) do |arg|
          case arg
          when Entity, Scriptable::Proxy::Agent
            1000
          when Class, Module
            class_depth(arg) * 100
          else
            1
          end
        end
      end

      def class_depth klass
        return 1 unless klass.is_a?(Class)

        depth = 1
        sup = klass
        depth += 1 while (sup = sup.superclass)
        depth
      end

      def ambiguous_result scan
        return Result.new(nil, scan.token) if scan.matched.empty?

        Result.new(scan.matched, scan.remainder)
      end

      def unambiguous_result scan
        return Result.new(nil, scan.token) unless scan.matched.one?

        Result.new(scan.matched.first, scan.remainder)
      end
    end
  end
end
