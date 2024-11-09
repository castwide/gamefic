# frozen_string_literal: true

module Gamefic
  module Proxy
    class PickEx < Base
      def fetch(narrative)
        narrative.pick!(*args)
      end
    end
  end
end
