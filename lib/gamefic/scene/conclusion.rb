module Gamefic

  # A Conclusion ends the Plot (or the character's participation in it).
  #
  class Scene::Conclusion < Scene::Custom
    def initialize &block
      @start = block
    end
  end
  
end
