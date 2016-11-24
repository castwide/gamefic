module Gamefic

  class Subplot
    module Element
      attr_reader :subplot
    end
    module Feature
      attr_reader :subplot
    end
    module Host
      # Get an array of all the current subplots.
      #
      # @return [Array<Subplot>]
      def subplots
        @subplots.clone
      end
      
      # Start a new subplot based on the provided class.
      #
      # @return [Subplot]
      def branch subplot_class
        subplot = subplot_class.new(self)
        @subplots.push subplot
        subplot
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
      if !player.subplot.nil?
        player.subplot.exeunt @player
      end
      player.instance_variable_set(:@subplot, self)
      players.push player
    end
    def exeunt player
      player.instance_variable_set(:@subplot, nil)
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
