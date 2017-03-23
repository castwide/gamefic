require 'gamefic/subplot'

module Gamefic

  module Plot::Host
    # Get an array of all the current subplots.
    #
    # @return [Array<Subplot>]
    def subplots
      p_subplots.clone
    end
    
    # Start a new subplot based on the provided class.
    #
    # @param [Class] The class of the subplot to be created (Subplot by default)
    # @return [Subplot]
    def branch subplot_class = Gamefic::Subplot, introduce: nil
      subplot = subplot_class.new(self, introduce: introduce)
      p_subplots.push subplot
      subplot
    end

    # Get the player's current subplot or nil if none exists.
    #
    # @return [Subplot]
    def subplot_for player
      subplots.each { |s|
        return s if s.players.include?(player)
      }
      nil
    end

    # Determine whether the player is involved in a subplot.
    #
    # @return [Boolean]
    def in_subplot? player
      !subplot_for(player).nil?
    end

    private
    def p_subplots
      @p_subplots ||= []
    end
  end

end
