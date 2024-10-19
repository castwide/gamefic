# frozen_string_literal: true

require 'set'
require 'gamefic/narrator/take'

module Gamefic
  # A narrative controller.
  #
  class Narrator
    # @return [Plot]
    attr_reader :plot

    def initialize(plot)
      @plot = plot
    end

    def cast(character = plot.introduce)
      plot.cast character
    end

    def uncast(character)
      plot.uncast character
    end

    # Start a turn.
    #
    def start
      start_takes
      plot.ready_blocks.each(&:call)
      plot.player_output_blocks.each(&:call)
      plot.turn
    end

    # Finish a turn.
    #
    def finish
      finish_takes
      plot.update_blocks.each(&:call)
    end

    def concluding?
      plot.concluding?
    end

    private

    def start_takes
      takes.concat(plot.players.map do |player|
        Take.new(player, plot.default_scene)
      end).each(&:start)
    end

    def finish_takes
      takes.each(&:finish)
      takes.clear
    end

    def takes
      @takes ||= []
    end
  end
end
