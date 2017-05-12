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
      raise 'Plot did not specify a player class' if @plot.player_class.nil?
      # @todo The plot itself can define name, etc.
      character = @plot.make @plot.player_class, name: 'yourself', synonyms: 'self myself you me', proper_named: true
      @user = user_class.new
      @user.connect character
      #@character.connect @user
      #@character
    end

    def run
      connect
      @plot.introduce @character
      #@user.update @character.state
      turn until @character.concluded?
      @user.update
      #print @user.flush
    end

    def turn
      @plot.ready
      unless @user.character.state[:options].nil?
        list = '<ol class="multiple_choice">'
        @user.character.state[:options].each { |o|
          list += "<li><a href=\"#\" rel=\"gamefic\" data-command=\"#{o}\">#{o}</a></li>"
        }
        list += "</ol>"
        @user.character.tell list
      end
      @user.update
      if @user.character.queue.empty?
        receive
      end
      @plot.update
    end

    def receive
      print @user.character.scene.prompt + ' '
      input = STDIN.gets
      @user.character.queue.push input unless input.nil?
    end
  end

end
