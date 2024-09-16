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

      # Get a query result for a given subject and token.
      #
      # @note This method is retained as a convenience for authors. Narratives
      #   should use Composer to build commands, as it provides more precise
      #   matching of tokens to valid response arguments. Authors can use
      #   #query to find entities that match a token regardless of whether the
      #   result matches an available response.
      #
      # @example
      #   respond :reds do |actor|
      #     reds = available(ambiguous: true).query(actor, 'red').match
      #     actor.tell "The red things you can see here are #{reds.join_and}."
      #   end
      #
      # @param subject [Gamefic::Entity]
      # @param token [String]
      # @return [Result]
      def query(subject, token)
        scan = scan(subject, token)
        ambiguous? ? ambiguous_result(scan) : unambiguous_result(scan)
      end

      # Get an array of entities that match the query from the context of the
      # subject.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def select _subject
        []
      end

      def scan subject, token, processors = Scanner.processors
        available = select(subject)
        processors.each do |processor|
          result = processor.scan(available, token)
          return result unless result.matched.empty?
        end
        Scanner::Result.unmatched(subject, token)
      end

      # True if the object is selectable by the subject.
      #
      # @param subject [Entity]
      # @param object [Array<Entity>, Entity]
      # @return [Boolean]
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

      # @param scan [Scanner::Result]
      def ambiguous_result scan
        return Result.new(nil, scan.token) if scan.matched.empty?

        Result.new(scan.matched, scan.remainder)
      end

      # @param scan [Scanner::Result]
      def unambiguous_result scan
        return Result.new(nil, scan.token) unless scan.matched.one?

        Result.new(scan.matched.first, scan.remainder)
      end
    end
  end
end
