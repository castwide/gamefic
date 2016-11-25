module Gamefic

  class Subplot
    module Element
      attr_reader :subplot
    end
    module Feature
      def subplots
        p_subplots.clone
      end
      private
      def p_subplots
        @p_subplots ||= []
      end
    end
    module Host
      # Get an array of all the current subplots.
      #
      # @return [Array<Subplot>]
      def subplots
        p_subplots.clone
      end
      
      # Start a new subplot based on the provided class.
      #
      # @param [Class] The class of the subplot to be created.
      # @return [Subplot]
      def branch subplot_class
        subplot = subplot_class.new(self)
        p_subplots.push subplot
        subplot
      end
      
      private
      def p_subplots
        @p_subplots ||= []
      end
    end
    
    attr_reader :plot, :entities, :players
    
    def initialize plot
      @plot = plot
      @entities = []
      @players = []
      post_initialize
    end
    def post_initialize
    end
    def make *args
      e = plot.make(*args)
      e.extend Gamefic::Subplot::Element
      e.instance_variable_set(:@subplot, self)
      entities.push e
      e
    end
    def introduce player
      player.send(:p_subplots).push self
      players.push player
    end
    def exeunt player
      player.send(:p_subplots).delete self
      players.delete player
    end
    def conclude
      entities.each { |e|
        e.destroy
      }
      players.each { |p|
        exeunt p
      }
    end
  end
  
end
