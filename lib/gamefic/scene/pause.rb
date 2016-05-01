module Gamefic

  class Scene::Pause < Scene::Custom
    def initialize prompt = nil, &block
      @prompt = prompt
      @start = block
    end
    def start actor
      @start_scene = actor.scene
      super
    end
    def finish actor, input
      actor.cue :active if (actor.scene == @start_scene and actor.next_scene.nil?)
    end
    def prompt
      @prompt ||= "Press Enter to continue..."
    end
  end
  
end
