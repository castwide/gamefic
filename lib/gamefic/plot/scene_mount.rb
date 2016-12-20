class NotConclusionError < Exception
end

module Gamefic

  module Plot::SceneMount
    # Create a multiple-choice scene.
    # The user will be required to make a valid choice to continue
    #
    # @yieldparam [Character]
    # @yieldparam [String]
    def multiple_choice key, options, &block
      scenes[key] = Scene::MultipleChoice.new(
        options: options,
        finish: block
      )
    end
    
    # Create a yes-or-no scene.
    # The user will be required to answer Yes or No to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [String] "yes" or "no"
    def yes_or_no key, prompt = nil, &block
      scenes[key] = Scene::YesOrNo.new(prompt, &block)
    end
    
    # Create a scene with a prompt.
    # This scene will use the provided block to process arbitrary input
    # from the user.
    #
    # @param key [Symbol] A unique name for the scene.
    # @param prompt [String] The input prompt to display to the user.
    # @yieldparam [Character]
    # @yieldparam [String]
    def question key, prompt, &block
      scenes[key] = Scene::Question.new prompt, &block
    end
    
    # Create a scene that pauses the game.
    # This scene will execute the specified block and wait for input
    # from the user (e.g., pressing Enter) to continue.
    #
    # @param key [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    def pause key, &block
      scenes[key] = Scene::Pause.new &block
    end
    
    # Create a conclusion.
    # The game will end after this scene is complete.
    #
    # @param key [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    def conclusion key, &block
      scenes[key] = Scene::Conclusion.new &block
    end
    
    # Create a generic scene.
    # After the scene is complete, it will automatically start the next
    # prepared scene, or the :active scene if none is prepared.
    #
    # @param [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    def scene key, &block
      scenes[key] = Scene::Passive.new &block
    end
    
    # Choose a new scene based on a list of options.
    # This is a specialized type of multiple-choice scene that determines
    # which scene to cue based on a Hash of choices and scene keys.
    #
    # @example Select a scene
    #   multiple_scene :select_one_or_two, { "one" => :scene_one, "two" => :scene_two }
    #   scene :scene_one do |actor|
    #     actor.tell "You went to scene one"
    #   end
    #   scene :scene_two do |actor|
    #     actor.tell "You went to scene two"
    #   end
    #   introduction do |actor|
    #     actor.cue :select_one_or_two # The actor will be prompted to select "one" or "two" and get sent to the corresponding scene
    #   end
    #
    # @param key [Symbol] A unique name for the scene.
    # @param map [Hash] A Hash of options and associated scene keys.
    def multiple_scene key, map
      scenes[key] = Scene::MultipleChoice.new(
        options: map.keys,
        finish: proc { |actor, input|
          actor.cue map[input.choice]
        }
      )
    end

  end

end
