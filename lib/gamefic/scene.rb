# frozen_string_literal: true

module Gamefic
  # Narratives use scenes to process game turns. The start of a scene defines
  # the output to be sent to the player. The finish processes player input.
  #
  module Scene
    require 'gamefic/scene/default'
    require 'gamefic/scene/activity'
    require 'gamefic/scene/multiple_choice'
    require 'gamefic/scene/pause'
    require 'gamefic/scene/yes_or_no'
    require 'gamefic/scene/conclusion'
  end
end
