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
    
    private
    def p_subplots
      @p_subplots ||= []
    end
  end

end
