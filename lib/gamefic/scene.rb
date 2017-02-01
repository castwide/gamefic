require 'gamefic/scene_data'

module Gamefic

  module Scene
    autoload :Base, 'gamefic/scene/base'
    autoload :Custom, 'gamefic/scene/custom'
    autoload :Active, 'gamefic/scene/active'
    autoload :Pause, 'gamefic/scene/pause'
    autoload :Conclusion, 'gamefic/scene/conclusion'
    autoload :MultipleChoice, 'gamefic/scene/multiple_choice'
    autoload :MultipleScene, 'gamefic/scene/multiple_scene'
    autoload :YesOrNo, 'gamefic/scene/yes_or_no'
  end
  
end
