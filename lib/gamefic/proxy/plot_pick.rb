# frozen_string_literal: true

module Gamefic
  class Proxy
    class PlotPick < Base
      def select narrative
        raise? ? narrative.plot.pick!(*args) : narrative.plot.pick(*args)
      end
    end
  end
end
