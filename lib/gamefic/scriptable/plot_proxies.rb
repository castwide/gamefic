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

      def plot_pick *args
        Proxy.new(:plot_pick, args)
      end
      alias lazy_plot_pick plot_pick
      alias _plot_pick plot_pick

      def plot_pick! *args
        Proxy.new(:plot_pick!, args)
      end
      alias lazy_plot_pick! plot_pick!
      alias _plot_pick! plot_pick!
    end
  end
end
