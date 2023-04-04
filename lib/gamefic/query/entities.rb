module Gamefic
  module Query
    class Entities
      include Abstract

      # @param query [Class<Gamefic::Query::Abstract>] Gemeral, Relative, or Textual
      # @param args [Array<Object>]
      def initialize query, *args, ambiguous: false, **opts
        @query = query
        @args = args
        @ambiguous = ambiguous
        @opts = opts
      end

      # @return [Result]
      def query(subject, token)
        available = @query.match(subject, *process_args(subject), **@opts)
        scan = Scanner.scan(available, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end

      def precision
        @precision ||= calculate_precision
      end

      def ambiguous?
        @ambiguous
      end

      private

      def calculate_precision
        result = @query.precision
        result -= 1000 if ambiguous?
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
