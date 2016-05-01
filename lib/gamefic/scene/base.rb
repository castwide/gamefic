module Gamefic::Scene
  
  class Base
    def prompt
      @prompt ||= '>'
    end
    def start actor
      
    end
    def finish actor, input
      
    end
    def state
      self.class.to_s.split('::').last
    end
  end
  
end
