# frozen_string_literal: true

module Gamefic
  module Block
    class Seed < Base
      def build(narrative)
        narrative.stage &code
      end
    end
  end
end
