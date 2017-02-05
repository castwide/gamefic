require 'gamefic/plot'

module Gamefic

  class Subplot
    include Stage
    
    attr_reader :plot
    attr_writer :denied_message

    mount Plot::Entities
    mount Plot::CommandMount
    mount Plot::Callbacks
    mount Plot::SceneMount
    expose :plot, :conclude

    def initialize plot, introduce: nil
      @plot = plot
      @concluded = false
      post_initialize
      playbook.freeze
      self.introduce introduce unless introduce.nil?
    end

    def post_initialize
    end

    def default_scene
      plot.default_scene
    end

    def default_conclusion
      plot.default_conclusion
    end

    def playbook
      @playbook ||= plot.playbook.dup
    end

    # HACK: Always assume subplots are running for the sake of entity destruction    
    def running?
      true
    end

    def denied_message
      @denied_message ||= 'You are already involved in another subplot.'
    end

    def introduce player
      if plot.subbed?(player)
        player.tell denied_message
      else
        super
      end
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
      conclude if players.empty?
      return if concluded?
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
