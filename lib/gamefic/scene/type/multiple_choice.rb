# frozen_string_literal: true

module Gamefic
  class Scene
    module Type
      class MultipleChoice < Base
        use_prop_class Scene::Props::MultipleChoice
      end
    end
  end
end
