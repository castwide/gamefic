# frozen_string_literal: true

module Gamefic
  module Block
    class Script < Base
      def build(narrative)
        contain(narrative).stage &code
      end

      private

      def contain(narrative)
        narrative.dup
                 .extend(ScriptMethods)
                 .freeze?
      end
    end
  end
end
