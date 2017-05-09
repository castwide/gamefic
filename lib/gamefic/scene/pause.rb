module Gamefic

  # Pause for user input.
  #
  class Scene::Pause < Scene::Custom

    def post_initialize
      self.type = 'Pause'
      self.prompt = 'Press enter to continue...'
    end

    def finish
      super
      actor.cue nil if actor.will_cue?(self)
    end
  end
  
end
