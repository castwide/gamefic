# frozen_string_literal: true

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
      scenes.concat(plot.players.map do |player|
        cue = player.next_cue || player.cue(plot.default_scene)
        cue.start
        player.rotate_cue
        cue
      end)
      plot.ready_blocks.each(&:call)
      plot.turn
      scenes.each(&:prepare)
      # scenes.each { |scene| scene.prepare(plot.player_output_blocks) }
    end

    # Finish a turn.
    #
    def finish
      scenes.each(&:finish)
      scenes.clear
      plot.update_blocks.each(&:call)
    end

    def concluding?
      plot.concluding?
    end

    private

    def scenes
      @scenes ||= []
    end
  end
end
