# frozen_string_literal: true

module Gamefic
  module Scriptable
    module PlotProxies
      def lazy_plot key
        Logging.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`lazy_plot` is deprecated. Use `plot_pick`, `plot_pick!, or pass the entity from the plot in a `config` option instead."
        Proxy.new(:attr, [:plot, key])
      end
      alias _plot lazy_plot

      def attr_plot attr
        define_method(attr) { plot.send(attr) }
      end

      def plot_pick *args
        Proxy::PlotPick.new(*args)
      end
      alias lazy_plot_pick plot_pick
      alias _plot_pick plot_pick

      def plot_pick! *args
        Proxy::PlotPick.new(*args)
      end
      alias lazy_plot_pick! plot_pick!
      alias _plot_pick! plot_pick!
    end
  end
end
