# frozen_string_literal: true

module Gamefic
  module Rig
    # A specialized MultipleChoice rig that only accepts Yes or No.
    #
    class YesOrNo < MultipleChoice
      use_props_class Props::YesOrNo
    end
  end
end
