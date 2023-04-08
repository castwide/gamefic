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

      # @param arguments [Array<Object>]
      # @param ambiguous [Boolean]
      def initialize *arguments, ambiguous: false
        @arguments = arguments
        @ambiguous = ambiguous
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
        @arguments.sum(@ambiguous ? -1000 : 0) do |arg|
          case arg
          when Gamefic::Entity, Gamefic::Proxy
            1000
          when Class, Module
            100
          else
            1
          end
        end
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
