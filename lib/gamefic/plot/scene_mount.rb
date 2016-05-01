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
    # @yieldparam [YesOrNoSceneData]
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
    # @yieldparam [SceneData]
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
    # After the scene is complete, it will automatically start the next cue.
    #
    # @param [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def scene key, &block
      #scene = SceneManager.new do |manager|
      #  manager.start do |actor, data|
      #    data.next_cue = :active
      #    block.call(actor, data) if !block.nil?
      #    cue actor, data.next_cue
      #    actor.scene.start actor
      #  end
      #  # Since generic scenes always cue a new scene, there's no reason to
      #  # define a finish block.
      #end
      #scene_managers[key] = scene
      scenes[key] = Scene::Passive.new &block
    end
    
    # Branch to a new scene based on a list of options.
    # This is a specialized type of multiple-choice scene that determines
    # which scene to cue based on a Hash of choices and scene keys.
    #
    # @example Select a scene
    #   branch :select_one_or_two, { "one" => :scene_one, "two" => :scene_two }
    #   scene :scene_one do |actor|
    #     actor.tell "You went to scene one"
    #   end
    #   scene :scene_two do |actor|
    #     actor.tell "You went to scene two"
    #   end
    #   introduction do |actor|
    #     cue actor, :select_one_or_two # The actor will be prompted to select "one" or "two" and get sent to the corresponding scene
    #   end
    #
    # @param key [Symbol] A unique name for the scene.
    # @param options [Hash] A Hash of options and associated scene keys.
    def branch key, options
      #multiple_choice key, *options.keys do |actor, data|
      #  cue actor, options[data.selection]
      #end
    end

    # Set the next scene for the character.
    # This is functionally identical to #cue, but it also raises an
    # exception if the selected scene is not a Concluded state.
    #
    # @param actor [Character] The character being cued
    # @param key [Symbol] The name of the scene
    def conclude actor, key
      #key = :concluded if key.nil?
      #manager = scene_managers[key]
      #if manager.state != "Concluded"
      #  raise NotConclusionError("Cued scene '#{key}' is not a conclusion")
      #end
      #cue actor, key
      actor.cue key
    end
    
  end

end
