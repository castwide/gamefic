module Gamefic
  module Query
    # @abstract
    class Base
      def initialize *args, ambiguous: false, eid: nil
        @args = args
        @ambiguous = false
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
        @args.each do |arg|
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
        @args.map do |arg|
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
