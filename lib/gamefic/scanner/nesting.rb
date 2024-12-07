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
        return unmatched_result unless token =~ NEST_REGEXP

        denest
      end

      private

      def denest
        near = selection
        far = selection
        parts = token.split(NEST_REGEXP)
        until parts.empty?
          current = parts.pop
          last_result = subprocessor.scan(near, current)
          last_result = subprocessor.scan(far, current) if last_result.matched.empty? && near != far
          return unmatched_result if last_result.matched.empty? || last_result.matched.length > 1

          near = last_result.matched.first.children & selection
          far = last_result.matched.first.flatten & selection
        end
        last_result
      end
    end
  end
end
