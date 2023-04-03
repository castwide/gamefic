module Gamefic
  module Query
    class Definition
      NEST_REGEXP = / in | on | of | from | inside | from inside /.freeze

      class Result
        attr_reader :match

        attr_reader :remainder

        def initialize match, remainder
          @match = match
          @remainder = remainder
        end
      end

      # @param query [Class] Gemeral, Relative, or Textual
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
        1000 # @todo Finish this
      end

      def ambiguous?
        @ambiguous
      end

      private

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

      def nested?(token)
        !token.match(NEST_REGEXP).nil?
      end

      def denest(objects, token)
        parts = token.split(NEST_REGEXP)
        current = parts.pop
        last_result = objects.select { |e| e.specified?(current) }
        last_result = objects.select { |e| e.specified?(current, fuzzy: true) } if last_result.empty?
        until parts.empty?
          current = "#{parts.last} #{current}"
          result = last_result.select { |e| e.specified?(current) }
          result = last_result.select { |e| e.specified?(current, fuzzy: true) } if result.empty?
          break if result.empty?
          parts.pop
          last_result = result
        end
        return [] if last_result.empty? or last_result.length > 1
        return last_result if parts.empty?
        denest(last_result[0].children, parts.join(' '))
      end
    end
  end
end
