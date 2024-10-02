# frozen_string_literal: true

module Gamefic
  module Scriptable
    module PlotProxies
      def lazy_plot key
        Proxy.new(:attr, [:plot, key])
      end
      alias _plot lazy_plot

      def attr_plot attr
        define_method(attr) { plot.send(attr) }
      end
    end
  end
end
