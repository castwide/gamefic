# frozen_string_literal: true

module Gamefic
  # A narrative controller.
  #
  class Narrator
    # @return [Plot]
    attr_reader :plot

    def initialize(plot)
      @plot = plot
      last_cues
    end

    # Cast a player character in the plot.
    #
    # @param character [Actor, Active]
    # @return [Actor, Active]
    def cast(character = plot.introduce)
      plot.cast character
    end

    # Uncast a player character from the plot.
    #
    # @param character [Actor, Active]
    # @return [Actor, Active]
    def uncast(character)
      plot.uncast character
    end

    def players
      plot.players
    end

    # Start a turn.
    #
    # @return [void]
    def start
      next_cues
      plot.ready_blocks.each(&:call)
      plot.turn
      cues.each(&:prepare)
    end

    # Finish a turn.
    #
    # @return [void]
    def finish
      cues.each(&:finish)
      cues.clear
      plot.update_blocks.each(&:call)
    end

    def concluding?
      plot.concluding?
    end

    private

    # @return [Array<Active::Cue>]
    def cues
      @cues ||= []
    end

    # @return [void]
    def last_cues
      cues.replace(plot.players.map(&:last_cue))
          .compact
    end

    # @return [void]
    def next_cues
      cues.replace(plot.players.map { |player| player.next_cue || player.cue(plot.default_scene) })
          .each(&:start)
    end
  end
end
