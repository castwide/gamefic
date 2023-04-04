module Gamefic
  module Query
    # @abstract
    class Base
      attr_reader :arguments

      attr_reader :ambiguous

      attr_reader :eid

      def initialize *arguments, ambiguous: false, eid: nil
        @arguments = arguments
        @ambiguous = ambiguous
        @eid = eid
      end

      # @return [Result]
      def query(subject, token)
        raise 'Not implemented'
      end

      def precision
        @precision ||= calculate_precision
      end

      def ambiguous?
        @ambiguous
      end

      private

      def calculate_precision
        prec = 0
        @arguments.each do |arg|
          if arg.is_a?(Class)
            prec += 500
          elsif arg.is_a?(Module) || arg.is_a?(Symbol)
            prec += 100
          end
        end
        prec += 1000 if @eid
        prec -= 1000 if @ambiguous
        prec
      end

      def ambiguous_result scan
        return Result.new(nil, scan.token) if scan.matched.empty?

        Result.new(scan.matched, scan.remainder)
      end

      def unambiguous_result scan
        return Result.new(nil, scan.token) unless scan.matched.one?

        Result.new(scan.matched.first, scan.remainder)
      end

      def process_args(_subject)
        @arguments.map do |arg|
          case arg
          when Proc
            arg.call
          else
            arg
          end
        end
      end
    end
  end
end
