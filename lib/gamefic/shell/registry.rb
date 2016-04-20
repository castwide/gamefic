module Gamefic
  class Shell
    module Registry
      @commands = {}
      def self.register cmd, cls
        @commands[cmd] = cls
      end
      def self.get_command_class cmd
        @commands[cmd]
      end
    end
  end
end
