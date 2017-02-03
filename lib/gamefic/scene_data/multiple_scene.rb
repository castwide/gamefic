module Gamefic

  class SceneData::MultipleScene < SceneData::MultipleChoice
    def options
      scene_map.keys
    end

    def map choice, scene
      scene_map[choice] = scene
    end

    def scene_for choice
      scene_map[choice]
    end

    def scene_map
      @scene_map ||= {}
    end
  end

end
