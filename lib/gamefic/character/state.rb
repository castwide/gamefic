class Gamefic::Character
  module State
    # Get a hash that describes the current state of the character.
    # The hash should be expressible in JSON.
    #
    # This method is in an include so that it can be extended by other
    # modules.
    #
    # @return [Hash]
    def state
      {
        output: (user.nil? ? nil : user.flush),
        prompt: prompt,
        scene: scene.type,
        busy: !queue.empty?
      }
    end
  end
end
