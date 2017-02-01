module Gamefic

  class SceneData::MultipleScene < SceneData::MultipleChoice
    attr_accessor :selection
    attr_accessor :number
    def options
      scene_map.keys
    end

    def map choice, scene
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
