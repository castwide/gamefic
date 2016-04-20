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
      if !cls.nil?
        cls.new.run ARGV
      else
        raise "Command not recognized: #{command}"
      end
    end
  end
  
end
