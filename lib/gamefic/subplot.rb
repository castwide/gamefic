require 'gamefic/plot'

module Gamefic

  class Subplot
    include Plot::EntityMount

    # TODO: Entities should not need to be aware of plots or subplots
    #module Element
    #  attr_reader :subplot
    #end
    module Feature
      def subplots
        p_subplots.clone
      end
      private
      def p_subplots
        @p_subplots ||= []
      end
    end
    
    attr_reader :plot
    
    def initialize plot, feature:nil
      @plot = plot
      @concluded = false
      post_initialize
      yield(self) if block_given?
      introduce feature unless feature.nil?
    end
    def post_initialize
    end
    #def make *args
      #e = plot.make(*args)
      #e.extend Gamefic::Subplot::Element
      #e.instance_variable_set(:@subplot, self)
      #entities.push e
      #e
    #end
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
        destroy e
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
