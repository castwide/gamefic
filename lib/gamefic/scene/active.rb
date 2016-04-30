module Gamefic

  class Scene::Active
    def start actor
      # TODO Anything necessary here?
    end
    def finish actor, input
      actor.perform input
    end
  end
  
end
