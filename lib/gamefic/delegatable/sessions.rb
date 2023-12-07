module Gamefic
  module Delegatable
    module Sessions
      # A hash of data that persists with the narrative.
      #
      # Sessions are useful for tracking data that is necessary to the story
      # but is not practical to attach to a specific entity, such as boolean
      # flags that indicate whether or not a story event has occurred.
      #
      # @return [Hash]
      attr_reader :session
    end
  end
end
