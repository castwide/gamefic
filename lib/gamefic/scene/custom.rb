module Gamefic
  
  # A Custom Scene is a generic scene that allows for complete configuration
  # of its behavior upon instantiation. It is suitable for direct instantion
  # or extension by other Scene classes.
  #
  class Scene::Custom < Scene::Base
    def initialize config = {}
      @start = config[:start]
      @finish = config[:finish]
      @prompt = config[:prompt]
    end
    def start actor
      @start.call(actor) unless @start.nil?
    end
    def finish actor, input
      @finish.call(actor, input) unless @finish.nil?
    end
  end
  
end
