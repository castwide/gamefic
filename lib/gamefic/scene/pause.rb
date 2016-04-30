module Gamefic

  class Scene::Pause < Scene::Custom
    def initialize prompt = nil, &block
      @prompt = prompt
      @start = block
    end
    def finish actor, input
      actor.prepare :active if actor.next_scene.nil?
    end
    def prompt
      @prompt ||= "Press Enter to continue..."
    end
  end
  
end
