require 'gamefic/plot'

module Gamefic

  class Subplot
    include Plot::Entities
    include Plot::CommandMount
    include Plot::Callbacks
    
    attr_reader :plot
    
    def initialize plot, introduce: nil
      @plot = plot
      @concluded = false
      post_initialize
      playbook.freeze
      self.introduce introduce unless introduce.nil?
    end

    def post_initialize
    end

    def playbook
      @playbook ||= plot.playbook.dup
    end

    # HACK: Always assume subplots are running for the sake of entity destruction    
    def running?
      true
    end

    def introduce player
      p_players.push player
      player.playbook = playbook
    end

    def exeunt player
      player.playbook = plot.playbook
      p_players.delete player
    end

    def conclude
      @concluded = true
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

    def ready
      playbook.freeze
      call_ready
      call_player_ready
    end

    def update
      call_player_update
      call_update
    end
  end
  
end
