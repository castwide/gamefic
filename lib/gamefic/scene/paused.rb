module Gamefic

  class PausedSceneManager < SceneManager
    def scene_class
      PausedScene
    end
    def data_class
      PausedSceneData
    end
    def state
      @state ||= "Paused"
    end
    def prompt
      @prompt ||= "Press enter to continue..."
    end
  end
  
  class PausedSceneData < SceneData
    attr_accessor :next_cue
  end
  
  class PausedScene < Scene
  
  end

end
