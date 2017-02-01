module Gamefic

  class Scene::MultipleScene < Scene::MultipleChoice
    def data_class
      SceneData::MultipleScene
    end

    def finish actor, input
      data = super
      unless data.selection.nil?
        actor.cue data.scene_for(data.selection)
      end
    end
  end
end
