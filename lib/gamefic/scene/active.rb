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
        last_order = actor.perform data.input
        actor.instance_variable_set(:@last_order, last_order)
      else
        @finish.call actor, data
      end
    end
  end

end
