# frozen_string_literal: true

module Gamefic
  module Block
    class Script < Base
      def build(narrative)
        narrative.stage &code
      end
    end
  end
end
