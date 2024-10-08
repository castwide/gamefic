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

      attr_accessor :narrative

      # @raise [ArgumentError] if any of the arguments are nil
      #
      # @param arguments [Array<Object>]
      # @param ambiguous [Boolean]
      # @param name [String]
      def initialize *arguments, ambiguous: false, name: self.class.to_s
        raise ArgumentError, "nil argument in query" if arguments.any?(&:nil?)

        @arguments = arguments
        @ambiguous = ambiguous
        @name = name
      end

      # Get a query result for a given subject and token.
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
        first_pass = Scanner.scan(span(subject), token)
        if ambiguous?
          ambiguous_result(first_pass.filter(*normalized_arguments))
        elsif first_pass.match.one?
          unambiguous_result(first_pass.filter(*normalized_arguments))
        else
          unambiguous_result(first_pass)
        end
      end
      alias filter query

      # Get an array of entities that match the arguments from the context of
      # the subject.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def select subject
        span(subject).that_are(*normalized_arguments)
      end

      # Get an array of entities that are candidates for selection from the
      # context of the subject. These are the entities that #select will
      # filter through query's arguments.
      #
      # Subclasses should override this method.
      #
      # @param subject [Entity]
      # @return [Array<Entity>]
      def span _subject
        []
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

      def name
        @name || self.class.to_s
      end

      def inspect
        "##{ambiguous? ? '*' : ''}#{name}(#{normalized_arguments.map(&:inspect).join(', ')})"
      end

      private

      def calculate_precision
        normalized_arguments.sum(@ambiguous ? -1000 : 0) do |arg|
          case arg
          when Entity, Proxy, Proxy::Base
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

        Result.new(scan.matched.first, scan.remainder, scan.strictness)
      end

      def normalized_arguments
        @normalized_arguments ||= arguments.map do |arg|
          case arg
          when Proxy, Proxy::Base
            arg.fetch(narrative)
          when String
            proc do |entity|
              arg.keywords.all? { |word| entity.keywords.include?(word) }
            end
          else
            arg
          end
        end
      end
    end
  end
end
