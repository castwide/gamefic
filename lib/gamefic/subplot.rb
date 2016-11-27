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
      # @param [Class] The class of the subplot to be created (Subplot by default)
      # @return [Subplot]
      def branch subplot_class = Subplot, &block
        subplot = subplot_class.new(self, &block)
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
      @concluded = false
      post_initialize
      yield(self) if block_given?
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
      concluded = true
      entities.each { |e|
        e.destroy
      }
      players.each { |p|
        exeunt p
      }
    end
    def concluded?
      @concluded
    end
  end
  
end
