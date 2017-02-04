module Gamefic

  # Basic functionality for running a single-player game from a console.
  #
  class Engine::Base
    attr_writer :user_class
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
      @character = @plot.make Character, name: 'yourself', synonyms: 'self myself you me', proper_named: true
      @user = user_class.new
      @character.connect @user
      @character
    end

    def run
      connect
      @plot.introduce @character
      turn until @character.concluded?
      print @user.flush
    end

    def turn
      @plot.ready
      print @user.flush
      if @character.queue.empty?
        receive
      end
      @plot.update
      print @user.flush
    end

    def receive
      print @character.scene.prompt_for(@character) + ' '
      input = STDIN.gets
      @character.queue.push input unless input.nil?
      puts ''
    end
  end

end
