module Gamefic

  class Scene::Pause < Scene::Custom
    def initialize prompt = nil, &block
      @prompt = prompt
      @start = block
    end
  end
  
end
