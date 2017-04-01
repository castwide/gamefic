require 'gamefic/plot'

module Gamefic

  class Subplot

    attr_reader :plot
    attr_writer :denied_message

    include Plot::Theater
    include Plot::Entities
    include Plot::Commands
    include Plot::Callbacks
    include Plot::Scenes
    include Plot::Articles

    class << self
      attr_reader :start_proc

      private

      def on_start &block
        @start_proc = block
      end
    end

    def initialize plot, introduce: nil
      @plot = plot
      @concluded = false
      stage &self.class.start_proc unless self.class.start_proc.nil?
      playbook.freeze
      self.introduce introduce unless introduce.nil?
    end

    def subplot
      self
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
      if plot.in_subplot?(player)
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
