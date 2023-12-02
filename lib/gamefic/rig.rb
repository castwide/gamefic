# frozen_string_literal: true

module Gamefic
  # Gamefic provides a few different types of rigs to facilitate a variety of
  # scene types, such as Activity (text-based commands), MultipleChoice
  # (requiring the user to select from a list of options), and Pause. The
  # easiest way to author custom scenes is to block them using a predefined rig
  # and adding functionality through callbacks. Delegatable::Scenes provides
  # helper methods for defining scenes from Plot scripts.
  #
  module Rig
    require 'gamefic/rig/default'
    require 'gamefic/rig/activity'
    require 'gamefic/rig/multiple_choice'
    require 'gamefic/rig/pause'
    require 'gamefic/rig/yes_or_no'
    require 'gamefic/rig/conclusion'
  end
end
