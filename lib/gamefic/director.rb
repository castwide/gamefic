# frozen_string_literal: true

module Gamefic
  # The object that handles delegation between the plot and the theater.
  #
  class Director
    def initialize plot
      @plot = plot
      @delegated = Scriptable.public_instance_methods
    end

    def method_missing symbol, *args, **splat, &block
      if @delegated.include?(symbol)
        @plot.send symbol, @args, **splat, &block
      else
        super
      end
    end
  end
end
