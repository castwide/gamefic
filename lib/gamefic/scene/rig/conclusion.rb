module Gamefic
  class Scene
    module Rig
      # @todo Inheriting pause might not be the best option here. It's a
      #   temporary solution to let plots detect conclusion.
      class Conclusion < Pause
      end
    end
  end
end
