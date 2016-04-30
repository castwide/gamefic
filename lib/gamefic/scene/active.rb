module Gamefic

  class Scene::Active < Scene::Base
    def start actor
      # TODO Anything necessary here?
    end
    def finish actor, input
      actor.perform input
    end
  end
  
end
