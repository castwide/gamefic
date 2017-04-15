module Gamefic

  class SceneData::MultipleScene < SceneData::MultipleChoice
    def clear
      options.clear
      scene_map.clear
    end

    def map choice, scene
      options.push choice
      scene_map[choice] = scene
    end

    def scene_for choice
      scene_map[choice]
    end

    private

    def scene_map
      @scene_map ||= {}
    end
  end

end
