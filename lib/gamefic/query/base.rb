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

      # @return [Symbol, nil]
      attr_reader :eid

      # @param arguments [Array<Object>]
      # @param ambiguous [Boolean]
      # @param eid [Symbol, nil]
      def initialize *arguments, ambiguous: false, eid: nil
        @arguments = arguments
        @ambiguous = ambiguous
        @eid = eid
      end

      # @param subject [Gamefic::Entity]
      # @param token [String]
      # @return [Result]
      def query(subject, token)
        raise 'Not implemented'
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
        @arguments.sum(base_precision) do |arg|
          case arg
          when Class
            depth_of_class(arg) * 100
          when Module
            100
          else
            1
          end
        end
      end

      def base_precision
        (@eid ? 1000 : 0) + (@ambiguous ? -1000 : 0)
      end

      def depth_of_class(arg)
        result = 1
        cursor = arg.superclass
        until cursor.nil?
          result += 1
          cursor = cursor.superclass
        end
        result
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
