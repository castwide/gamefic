# frozen_string_literal: true

module Gamefic
  class Chapter < Narrative
    # @return [Plot]
    attr_reader :plot

    # @param [plot] Plot
    def initialize(plot)
      super
      @plot = plot
    end

    def included_scripts
      super - plot.included_scripts
    end
  end
end
