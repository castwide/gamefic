# frozen_string_literal: true

module Gamefic
  module Scanner
    # Fuzzy scanning for entities inside of other entities, e.g., `soc in draw`
    # would match `sock in drawer`.
    #
    class NuancedNesting < Nesting
      def subprocessor
        Nuanced
      end
    end
  end
end
