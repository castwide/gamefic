module Gamefic
  
  class Script::Text < Script::Base
    def initialize(path, code)
      @path = path
      @code = code
    end
    def read
      @code
    end
    def path
      @path
    end
  end
end
