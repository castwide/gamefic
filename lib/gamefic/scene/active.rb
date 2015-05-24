module Gamefic

  class ActiveSceneManager < SceneManager
    def scene_class
      ActiveScene
    end
    def state
      @state ||= "Active"
    end
  end
  
  class ActiveScene < Scene
    def finish actor, input
      @data.input = input
      if @finish.nil?
        actor.perform data.input
      else
        @finish.call actor, data
      end
    end
  end

end
