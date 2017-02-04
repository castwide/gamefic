require 'gamefic/plot'

module Gamefic

  class Subplot < Plot
    attr_reader :plot
    
    def initialize plot, feature:nil
      @plot = plot
      @playbook = plot.playbook.clone
      @concluded = false
      post_initialize
      yield(self) if block_given?
      introduce feature unless feature.nil?
    end

    def post_initialize
    end

    # HACK: Always assume subplots are running for the sake of entity destruction    
    def running?
      true
    end

    def introduce player
      p_players.push player
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
