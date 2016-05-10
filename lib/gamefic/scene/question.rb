module Gamefic

  # Question Scenes handle a string of arbitrary input. Examples include
  # asking for a password, a destination, or a topic of conversation. The
  # finish block is solely responsible for processing the answer.
  # After the scene is finished, the :active scene will automatically be cued
  # if no other scene has been cued or prepared.
  #
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
