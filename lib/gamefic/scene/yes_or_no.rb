module Gamefic

  # Prompt the user to answer "yes" or "no". The scene will accept variations
  # like "YES" or "n" and normalize the answer to "yes" or "no" in the finish
  # block. After the scene is finished, the :active scene will be cued if no
  # other scene has been prepared or cued.
  #
  class Scene::YesOrNo < Scene::Custom
    def data_class
      Scene::Data::YesOrNo
    end

    def finish actor, input
      data = finish_data_for(actor, input)
      if data.yes? or data.no?
        this_scene = actor.scene
        do_finish_block actor, data
        actor.cue :active if (actor.scene == this_scene and actor.next_scene.nil?)
      else
        actor.tell data.invalid_message
      end
    end
  end

end
