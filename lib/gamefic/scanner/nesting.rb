# frozen_string_literal: true

module Gamefic
  module Scanner
    # Strict scanning for entities inside of other entities, e.g., `sock inside drawer`.
    #
    class Nesting < Base
      NEST_REGEXP = / in | on | of | from | inside | inside of | from inside | off | out | out of /.freeze

      def subprocessor
        Strict
      end

      def scan
        return Result.unmatched(selection, token) unless token =~ NEST_REGEXP

        denest selection, token
      end

      private

      def denest objects, token
        parts = token.split(NEST_REGEXP)
        until parts.empty?
          current = parts.pop
          last_result = subprocessor.scan(objects, current)
          return Result.unmatched(selection, token) if last_result.matched.empty? || last_result.matched.length > 1

          objects = last_result.matched.first.children
        end
        last_result
      end
    end
  end
end
