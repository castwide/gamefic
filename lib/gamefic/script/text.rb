module Gamefic
  
  class Script::Text < Script::Base
    attr_reader :path, :absolute_path
    def initialize path, code, absolute_path = nil
      @path = path
      @code = code
      @absolute_path = absolute_path || path
    end
    def read
      @code
    end
  end
end
