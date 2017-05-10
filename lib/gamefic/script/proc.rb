module Gamefic
  
  class Script::Proc < Script::Text
    def read
      nil
    end
    def block
      @code
    end
  end
end
