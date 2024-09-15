# frozen_string_literal: true

module Gamefic
  module Scanner
    class Nesting < Default
      NEST_REGEXP = / in | on | of | from | inside | inside of | from inside | off /.freeze

      def scan
        return Result.unmatched(selection, token) unless token =~ NEST_REGEXP

        denest selection, token
      end

      private

      def denest objects, token
        parts = token.split(NEST_REGEXP)
        current = parts.pop
        last_result = Default.new(objects, current).scan
        until parts.empty?
          current = "#{parts.last} #{current}"
          result = Default.new(last_result.matched, current).scan
          break if result.matched.empty?

          parts.pop
          last_result = result
        end
        return Result.unmatched(selection, token) if last_result.matched.empty? || last_result.matched.length > 1
        return last_result if parts.empty?

        denest(last_result.matched.first.children, parts.join(' '))
      end
    end
  end
end
