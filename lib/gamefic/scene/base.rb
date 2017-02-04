module Gamefic
  
  # The Base Scene is not intended for instantiation. Other Scene classes
  # should inherit from it.
  #
  class Scene::Base
    def start actor
    end

    def finish actor, input
    end
    
    # Get the prompt to be displayed to the user when accepting input.
    #
    # @return [String] The text to be displayed.
    def prompt_for actor
      '>'
    end

    def type
      self.class.to_s.split('::').last
    end
  end

end
