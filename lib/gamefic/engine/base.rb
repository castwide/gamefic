module Gamefic

  class Engine::Base
    attr_writer :user_class

    def initialize(plot)
      @plot = plot
    end

    def post_initialize
      # Override in subclasses
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
      #if !@user.character[:test_queue].nil? and @user.character[:test_queue].length > 0
      #  test_command = @user.character[:test_queue].shift
      #  @user.character.tell "[TESTING] #{@plot.scenes[@user.character.scene].prompt} #{test_command}"
      #  @user.character.queue.push test_command
      #else
        #input = get_input(@plot.scenes[@character.scene].prompt)
        input = @user.recv(@plot.scenes[@character.scene].prompt)
        @character.queue.push input unless input.nil?
      #end
      @plot.update
      print @user.flush
    end
  end

  def self.start plot, config = {}
    engine = self.new(plot)
    engine.connect config
    engine.run
  end

  private

  def get_input(prompt)
  end

end
