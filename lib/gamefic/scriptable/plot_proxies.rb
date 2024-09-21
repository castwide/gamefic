# frozen_string_literal: true

module Gamefic
  module Scriptable
    module PlotProxies
      def plot_attr key
        Proxy.new(:attr, [:plot, key])
      end
    end
  end
end
