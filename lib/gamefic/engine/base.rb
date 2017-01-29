module Gamefic
  class Engine::Base
    attr_writer :user_class

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
      @plot.introduce @character
      print @user.flush
      turn until @plot.concluded?(@character)
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
      print @plot.scenes[@character.scene].prompt + ' '
      input = STDIN.gets
      @character.queue.push input unless input.nil?
      puts ''
    end
  end
end
