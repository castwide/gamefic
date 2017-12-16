module Gamefic
  # Basic functionality for running a single-player game from a console.
  #
  class Engine::Base
    # @return [Class]
    attr_writer :user_class

    # @return [Gamefic::Plot]
    attr_reader :plot

    def initialize(plot)
      @plot = plot
      post_initialize
    end

    def post_initialize
      # Override in subclasses
    end

    def user_class
      @user_class ||= Gamefic::User::Base
    end

    def connect
      character = plot.get_player_character
      @user = user_class.new(self)
      plot.authorize @user, character
    end

    def run
      connect
      plot.introduce @user.character
      turn until @user.character.concluded?
      @user.update
    end

    def turn
      plot.ready
      @user.update
      if @user.character.queue.empty?
        receive
      end
      plot.update
    end

    def receive
      print @user.character.scene.prompt + ' '
      input = STDIN.gets
      @user.character.queue.push input unless input.nil?
    end
  end
end
