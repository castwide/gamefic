module Gamefic::Scene
  
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
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
