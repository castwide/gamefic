module Gamefic

  class Scene::MultipleScene < Scene::MultipleChoice
    def data_class
      SceneData::MultipleScene
    end

    def finish actor, input
      data = super
      if data.selection.nil?
        actor.tell data.invalid_message
      else
        actor.cue data.scene_for(data.selection)
      end
    end
  end
end
