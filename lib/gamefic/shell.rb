module Gamefic

  class Shell
    autoload :Command, 'gamefic/shell/command'
    
    def initialize
      @commands = {}
    end
    
    def register cmd, cls
      @commands[cmd] = cls
    end
    
    def execute
      command = ARGV[0]
      cls = @commands[command]
      if cls.nil?
        Gamefic::Shell::Command::Play.new.run(['play'] + ARGV)
      else
        cls.new.run ARGV
      end
    end
  end
  
end
