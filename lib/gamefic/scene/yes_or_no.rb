# frozen_string_literal: true

module Gamefic
  module Scene
    # A specialized MultipleChoice scene that only accepts Yes or No.
    #
    class YesOrNo < MultipleChoice
      use_props_class Props::YesOrNo
    end
  end
end
