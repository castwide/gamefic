module Gamefic

  class Scene::Conclusion < Scene::Custom
    def initialize &block
      @start = block
    end
  end
  
end
