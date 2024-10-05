# frozen_string_literal: true

module Gamefic
  class Proxy
    class Pick < Base
      def select narrative
        narrative.pick *args
      end
    end
  end
end
