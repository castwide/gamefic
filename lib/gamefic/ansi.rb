module Gamefic

  # Constants for ANSI codes, plus extras for custom formatting.
  module Ansi
    module Code
      class Custom < String
      
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
        BLOCK = Custom.new("block")
        HREF = Custom.new("href")
        IMAGE = Custom.new("image")
        SRC = Custom.new("src")
        UPPERCASE = Custom.new("uppercase")
        COMMAND = Custom.new("command")
      end
    end  
    def self.graphics_mode(*settings)
      "\e[#{settings.join(';')}m"
    end
  end

end
