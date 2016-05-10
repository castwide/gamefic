module Gamefic

  # Prompt the user to answer "yes" or "no". The scene will accept variations
  # like "YES" or "n" and normalize the answer to "yes" or "no" in the finish
  # block. After the scene is finished, the :active scene will be cued if no
  # other scene has been prepared or cued.
  #
  class Scene::YesOrNo < Scene::Custom
    def initialize prompt = nil, &block
      @prompt = prompt
      @finish = block
    end
    def finish actor, input
      answer = nil
      if input.downcase[0, 1] == "y"
        answer = "yes"
      elsif input.downcase[0, 1] == "n"
        answer = "no"
      end
      if answer.nil?
        actor.tell "Please enter Yes or No."
      else
        this_scene = actor.scene
        @finish.call actor, answer
        actor.cue :active if (actor.scene == this_scene and actor.next_scene.nil?)
      end
    end
  end

end
