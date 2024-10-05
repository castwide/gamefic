# frozen_string_literal: true

module Gamefic
  class Proxy
    class PlotPick < Base
      def select narrative
        narrative.plot.pick *args
      end
    end
  end
end
