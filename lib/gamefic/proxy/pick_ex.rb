# frozen_string_literal: true

module Gamefic
  module Proxy
    class PickEx < Base
      def select(narrative)
        narrative.pick!(*args)
      end
    end
  end
end
