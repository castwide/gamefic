# frozen_string_literal: true

module Gamefic
  module Scanner
    class FuzzyNesting < Nesting
      def subprocessor
        Fuzzy
      end
    end
  end
end
