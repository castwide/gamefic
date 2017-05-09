module Gamefic

  # Pause for user input.
  #
  class Scene::Pause < Scene::Custom
    def finish
      super
      actor.cue nil if actor.will_cue?(self)
    end
  end
  
end
