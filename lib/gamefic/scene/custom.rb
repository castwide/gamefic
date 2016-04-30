module Gamefic
  
  class Scene::Custom
    def initialize config = {}
      @start = config[:start]
      @finish = config[:finish]
      @prompt = config[:prompt]
    end
  end
  
end
