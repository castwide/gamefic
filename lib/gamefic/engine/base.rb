module Gamefic

  class Engine::Base
    def initialize(plot)
      @plot = plot
      post_initialize
    end

    def post_initialize
      # Override in subclasses
    end

    def set_user_class cls
      @user_class = cls
    end

    def user_class
      @user_class ||= Gamefic::User::Base
    end

    def connect user: user_class, character: Character, attributes: nil
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
      # TODO The base engine should not be concerned with plot tests
      if !@character[:test_queue].nil? and @character[:test_queue].length > 0
        test_command = @character[:test_queue].shift
        @character.tell "[TESTING] #{@plot.scenes[@character.scene].prompt} #{test_command}"
        @character.queue.push test_command
      else
        input = @user.recv(@plot.scenes[@character.scene].prompt)
        @character.queue.push input unless input.nil?
      end
      @plot.update
      print @user.flush
    end
  end

end
