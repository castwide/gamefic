module Gamefic

  class Scene::MultipleScene < Scene::Custom
    def data_class
      SceneData::MultipleScene
    end

    def finish actor, input
      data = super
      unless data.selection.nil?
        actor.cue data.scene_for(selection)
      end
    end
  end
end
