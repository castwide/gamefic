module Gamefic

  class ConcludedSceneManager < SceneManager
    def scene_class
      ConcludedScene
    end
    def state
      @state ||= "Concluded"
    end
  end
  
  class ConcludedScene < Scene
    # TODO: This class might need some logic for closing the game. Then again,
    # maybe not. The Concluded state might be enough for the plot to know what
    # to do. In fact, if the plot detects the Concluded state, it might never
    # get around to calling the scene's finish proc.
  end

end
