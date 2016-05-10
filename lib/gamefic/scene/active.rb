module Gamefic

  # Active Scenes handle the default command prompt, where input is parsed
  # into an Action performed by the Character. This is the default scene in
  # a Plot.
  #
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
