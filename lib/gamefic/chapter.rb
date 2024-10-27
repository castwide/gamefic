# frozen_string_literal: true

module Gamefic
  class Chapter < Narrative
    # @return [Plot]
    attr_reader :plot

    # @return [Hash]
    attr_reader :config

    # @param [plot] Plot
    def initialize(plot, **config)
      @plot = plot
      @concluding = false
      @config = config
      configure
      @config.freeze
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

    # Subclasses can override this method to handle additional configuration
    # options.
    #
    def configure; end
  end
end
