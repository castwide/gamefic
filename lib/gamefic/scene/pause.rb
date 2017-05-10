module Gamefic

  # Pause for user input.
  #
  class Scene::Pause < Scene::Custom
    def post_initialize
      self.type = 'Pause'
      self.prompt = 'Press enter to continue...'
    end
  end
  
end
