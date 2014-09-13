module Gamefic

  # Constants for ANSI codes, plus Extras for custom formatting.
  module Ansi
    module Code
      class Nonstandard < String
      
      end
      module Attribute
        NORMAL = 0
        BOLD = 1
        UNDERSCORE = 4
        BLINK = 5
        REVERSE = 7
        CONCEALED = 8
      end
      module Foreground
        BLACK = 30
        RED = 31
        GREEN = 32
        YELLOW = 33
        BLUE = 34
        MAGENTA = 35
        CYAN = 36
        WHITE = 37
      end
      module Background
        BLACK = 40
        RED = 41
        GREEN = 42
        YELLOW = 43
        BLUE = 44
        MAGENTA = 45
        CYAN = 46
        WHITE = 47
      end
      module Extra
        BLOCK = Nonstandard.new("block")
        HREF = Nonstandard.new("href")
        IMAGE = Nonstandard.new("image")
        SRC = Nonstandard.new("src")
        UPPERCASE = Nonstandard.new("uppercase")
        COMMAND = Nonstandard.new("command")
        IGNORED = Nonstandard.new("ignored")
      end
    end  
    def self.graphics_mode(*settings)
      ansi = settings.flatten.that_are_not(Code::Nonstandard)
      return '' if ansi.length == 0
      "\e[#{ansi.join(';')}m"
    end
  end

end
