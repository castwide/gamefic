module Gamefic

  class Scene::Active < Scene::Base
    def start actor
      # TODO Anything necessary here?
    end
    def finish actor, input
      last_order = actor.perform input
      # HACK Set the last_order here so inline performs don't set it
      actor.send(:last_order=, last_order)
    end
  end
  
end
