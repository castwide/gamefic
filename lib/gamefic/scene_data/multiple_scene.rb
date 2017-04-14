module Gamefic

  class SceneData::MultipleScene < SceneData::MultipleChoice
    def options
      #scene_map.keys
      p_option_keys.clone
    end

    def clear
      p_option_keys.clear
      p_option_scenes.clear
    end
    
    def map choice, scene
      #scene_map[choice] = scene
      p_option_keys.push choice
      p_option_scenes.push scene
    end

    def scene_for choice
      #scene_map[choice]
      index = p_option_keys.index(choice)
      p_option_scenes[index]
    end

    def scene_map
      @scene_map ||= {}
    end

    private

    def p_option_keys
      @p_option_keys ||= []
    end

    def p_option_scenes
      @p_option_scenes ||= []
    end
  end

end
