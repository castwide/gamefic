module Gamefic

  # Constants for ANSI codes, plus ExtraCodes for custom formatting.
  module Text::Ansi
    module Code
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
        BLOCK = :block
        PRE = :pre
        HREF = :href
        IMAGE = :image
        SRC = :src
        UPPERCASE = :uppercase
        COMMAND = :command
        IGNORED = :ignored
        LINE = :line
      end
    end  
    def self.graphics_mode(*settings)
      ansi = settings.flatten.that_are(Fixnum)
      return '' if ansi.length == 0
      "\e[#{ansi.join(';')}m"
    end
  end

end
