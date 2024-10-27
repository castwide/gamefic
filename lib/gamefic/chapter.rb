# frozen_string_literal: true

module Gamefic
  class Chapter < Narrative
    # @return [Plot]
    attr_reader :plot

    # @param [plot] Plot
    def initialize(plot)
      @plot = plot
      @concluding = false
      super()
    end

    def players
      plot.players
    end

    def conclude
      # @todo Void entities?
      @concluding = true
    end

    def concluding?
      @concluding
    end

    def self.bind_from_plot *methods
      methods.flatten.each do |method|
        define_method(method) { plot.send(method) }
        define_singleton_method(method) { Proxy::Attr.new(method) }
      end
    end

    def included_scripts
      super - plot.included_scripts
    end
  end
end
