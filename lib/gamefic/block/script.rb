# frozen_string_literal: true

module Gamefic
  module Block
    class Script < Base
      def build(narrative)
        contain(narrative).stage &code
      end

      private

      # @param narrative [Narrative]
      def contain(narrative)
        narrative.clone
                 .extend(ScriptMethods)
                 .freeze
      end
    end
  end
end
