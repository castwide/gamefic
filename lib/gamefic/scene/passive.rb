module Gamefic

  # Passive Scenes immediately cue another scene after they're finished. If no
  # scene has been cued or prepared, it defaults to the :active scene.
  #
  class Scene::Passive < Scene::Custom
    def initialize &block
      @start = block
    end
    def start actor
      this_scene = actor.scene
      super
      actor.cue :active if (actor.scene == this_scene and actor.next_scene.nil?)     
    end
  end
    
end
