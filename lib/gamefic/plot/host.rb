# frozen_string_literal: true

require 'gamefic/subplot'

module Gamefic
  class Plot
    # Methods for hosting and managing subplots.
    #
    module Host
      # Get an array of all the current subplots.
      #
      # @return [Array<Subplot>]
      def subplots
        @subplots ||= []
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
end
