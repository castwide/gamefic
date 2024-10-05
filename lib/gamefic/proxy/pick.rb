# frozen_string_literal: true

module Gamefic
  class Proxy
    class Pick < Base
      def select narrative
        raise? ? narrative.pick!(*args) : narrative.pick(*args)
      end
    end
  end
end
