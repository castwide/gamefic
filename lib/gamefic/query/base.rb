# frozen_string_literal: true

module Gamefic
  module Query
    # A base class for entity-based queries that can be applied to responses.
    # Each query matches a command token to an object that can be passed into
    # a response callback.
    #
    # Most queries return entities, but there are also queries for plain text
    # and integers.
    #
    class Base
      # @return [Array<Object>]
      attr_reader :arguments

      # @raise [ArgumentError] if any of the arguments are nil
      #
      # @param arguments [Array<Object>]
      # @param name [String]
      def initialize *arguments, name: self.class.to_s
        raise ArgumentError, "nil argument in query" if arguments.any?(&:nil?)

        @arguments = arguments
        @name = name
      end

      # Get a query result for a given subject and token.
      #
      # @param subject [Gamefic::Entity]
      # @param token [String]
      # @return [Result]
      def filter(subject, token)
        scan = Scanner.scan(select(subject), token)
        return Result.new(nil, scan.token) unless scan.matched.one?

        Result.new(scan.matched.first, scan.remainder, scan.strictness)
      end

      # Get an array of entities that match the arguments from the context of
      # the subject.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def select(subject)
        span(subject).that_are(*arguments)
      end

      # Get an array of entities that are candidates for selection from the
      # context of the subject. These are the entities that #select will
      # filter through query's arguments.
      #
      # Subclasses should override this method.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def span(_subject)
        []
      end

      # True if the object is selectable by the subject.
      #
      # @param subject [Entity]
      # @param object [Entity]
      # @return [Boolean]
      def accept?(subject, object)
        select(subject).include?(object)
      end

      # @return [Integer]
      def precision
        @precision ||= calculate_precision
      end

      def name
        @name || self.class.to_s
      end

      def inspect
        "#{name}(#{arguments.map(&:inspect).join(', ')})"
      end

      def bind(narrative)
        clone.tap do |query|
          query.instance_exec do
            @arguments = narrative.unproxy(@arguments)
          end
        end
      end

      def self.plain
        @plain ||= new
      end

      def self.span(subject)
        plain.span(subject)
      end

      private

      def calculate_precision
        arguments.sum(0) do |arg|
          case arg
          when Entity, Proxy::Base
            1000
          when Class, Module
            class_depth(arg) * 100
          else
            1
          end
        end
      end

      def class_depth(klass)
        return 1 unless klass.is_a?(Class)

        depth = 1
        sup = klass
        depth += 1 while (sup = sup.superclass)
        depth
      end
    end
  end
end
