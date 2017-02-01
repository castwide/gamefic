module Gamefic

  # Pause for user input.
  #
  class Scene::Pause < Scene::Custom
    def start actor
      data = start_data_for(actor)
      data.prompt = 'Press enter to continue...'
      do_start_block actor, data
    end
  end
  
end
