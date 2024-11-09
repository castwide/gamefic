# frozen_string_literal: true

module Gamefic
  module Proxy
    class Pick < Base
      def fetch(narrative)
        narrative.pick(*args)
      end
    end
  end
end
