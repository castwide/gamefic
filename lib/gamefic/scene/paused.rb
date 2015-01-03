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
    def finish actor, input
      if !@finish.nil?
        @finish.call actor, @data
      end
      if actor.scene.key != @data.next_cue
        actor.cue data.next_cue
      end
    end
  end

end
