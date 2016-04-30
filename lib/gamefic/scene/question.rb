module Gamefic

  class Scene::Question < Scene::Custom
    def initialize prompt, &block
      @prompt = prompt
      @finish = block
    end
    def finish actor, input
      this_scene = actor.scene
      super
      actor.cue :active if (actor.scene == this_scene and actor.next_scene.nil?)
    end
  end

end
