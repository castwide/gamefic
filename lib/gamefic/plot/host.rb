require 'gamefic/subplot'

module Gamefic
  # Methods for hosting and managing subplots.
  #
  module Plot::Host
    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      @subplots ||= []
    end

    # Start a new subplot based on the provided class.
    #
    # @param subplot_class [Class<Gamefic::Subplot>] The class of the subplot to be created (Subplot by default)
    # @return [Gamefic::Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil, next_cue: nil, **more
      subplot = subplot_class.new(self, introduce: introduce, next_cue: next_cue, **more)
      subplots.push subplot
      subplot
    end

    # Get the player's current subplots.
    #
    # @return [Array<Subplot>]
    def subplots_featuring player
      result = []
      subplots.each { |s|
        result.push s if s.players.include?(player)
      }
      result
    end

    # Determine whether the player is involved in a subplot.
    #
    # @return [Boolean]
    def in_subplot? player
      !subplots_featuring(player).empty?
    end
  end
end
