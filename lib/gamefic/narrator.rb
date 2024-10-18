# frozen_string_literal: true

module Gamefic
  # @note A turn runs start, send, receive, and finish.
  #
  # @todo Everything here is Hopeful Ruby.
  #
  class Narrator
    # @return [Plot]
    attr_reader :plot

    def initialize plot
      @plot = plot
    end

    # Start a turn.
    #
    def start
      plot.ready_blocks.each(&:call)
    end

    # Send output to players.
    def send
      plot.players.each do |player|
        # @todo Send the output
      end
    end

    # Receive input from players.
    #
    def receive
      plot.players.each do |player|
        # @todo Receive the input
      end
    end

    # Finish a turn.
    #
    def finish
      plot.update_blocks.each(&:call)
    end
  end
end
