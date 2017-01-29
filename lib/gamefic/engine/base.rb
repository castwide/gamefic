module Gamefic
  class Engine::Base
    def initialize(plot)
      @plot = plot
      post_initialize
    end

    def post_initialize
      # Override in subclasses
    end

    def set_user_class(cls)
      @user_class = cls
    end

    def user_class
      @user_class ||= Gamefic::User::Base
    end

    def connect(user: user_class, character: Character, attributes: nil)
      if attributes.nil?
        attributes = {
          name: 'yourself',
          synonyms: 'self myself you me',
          proper_named: true
        }
      end
      @user = user.new
      @character = @plot.make character, attributes
      @character.connect @user
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
        input = @user.recv(@plot.scenes[@character.scene].prompt)
        @character.queue.push input unless input.nil?
      end
      @plot.update
      print @user.flush
    end
  end
end
