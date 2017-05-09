module Gamefic

  # A Conclusion ends the Plot (or the character's participation in it).
  #
  class Scene::Conclusion < Scene::Custom
    def type
      @type ||= 'Conclusion'
    end
  end
  
end
