class NotConclusionError < Exception
end

module Gamefic

  module Plot::SceneMount
    # Get a Hash of SceneManager objects.
    #
    # @return [Hash<Symbol, SceneManager>]
    def scene_managers
      if @scene_managers.nil?
        @scene_managers ||= {}
        @scene_managers[:active] = ActiveSceneManager.new
        @scene_managers[:concluded] = ConcludedSceneManager.new
      end
      @scene_managers
    end
    
    # Create a multiple-choice scene.
    # The user will be required to make a valid choice to continue
    #
    # @yieldparam [Character]
    # @yieldparam [MultipleChoiceSceneData]
    def multiple_choice key, *args, &block
      scene_managers[key] = MultipleChoiceSceneManager.new do |config|
        config.start do |actor, data|
          data.options = args
        end
        config.finish(&block)
      end
    end
    
    # Create a yes-or-no scene.
    # The user will be required to answer Yes or No to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [YesOrNoSceneData]
    def yes_or_no key, prompt = nil, &block
      manager = YesOrNoSceneManager.new do |config|
        config.prompt = prompt
        config.finish do |actor, data|
          if data.answer.nil?
            actor.tell "Please answer Yes or No."
          else
            data.next_cue ||= :active
            block.call(actor, data)
          end
        end
      end
      scene_managers[key] = manager
    end
    
    # Create a scene with a prompt.
    # This scene will use the provided block to process arbitrary input
    # from the user.
    #
    # @param key [Symbol] A unique name for the scene.
    # @param prompt [String] The prompt message to display to the user.
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def prompt key, prompt, &block
      scene_managers[key] = SceneManager.new do |config|
        config.prompt = prompt
        config.finish do |actor, data|
          data.next_cue ||= :active
          block.call actor, data
        end
      end
      scene_managers[key].state = "Prompted"
    end
    
    # Create a scene that pauses the game.
    # This scene will execute the specified block and wait for input
    # from the user (e.g., pressing Enter) to continue.
    #
    # @param key [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def pause key, &block
      manager = PausedSceneManager.new do |config|
        config.start do |actor, data|
          data.next_cue = :active
          block.call actor, data
        end
      end
      scene_managers[key] = manager
    end
    
    # Create a conclusion.
    # The game will end after this scene is complete.
    #
    # @param key [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def conclusion key, &block
      manager = ConcludedSceneManager.new do |config|
        config.start(&block)
      end
      scene_managers[key] = manager
    end
    
    # Create a generic scene.
    # After the scene is complete, the character will automatically progress to the next cue.
    #
    # @param [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [SceneData]
    def scene key, &block
      scene = SceneManager.new do |manager|
        manager.start do |actor, data|
          data.next_cue = :active
          block.call(actor, data) if !block.nil?
          cue actor, data.next_cue
        end
        # Since generic scenes always cue a new scene, there's no reason to
        # define a finish block.
      end
      scene_managers[key] = scene
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
      multiple_choice key, *options.keys do |actor, data|
        cue actor, options[data.selection]
      end
    end
    
    # Cue a Character's next scene
    #
    # @param actor [Character] The character being cued
    # @param key [Symbol] The name of the scene
    def cue actor, key
      if !actor.scene.nil? and actor.scene.state == "Concluded"
        return
      end
      if key.nil?
        raise "Cueing scene with nil key"
      end
      manager = scene_managers[key]
      if manager.nil?
        raise "No '#{key}' scene found"
      else
        actor.scene = manager.prepare key
      end
      @scene
    end
    
    # This is functionally identical to #cue, but it also raises an
    # exception if the selected scene is not a Concluded state.
    #
    # @param actor [Character] The character being cued
    # @param key [Symbol] The name of the scene
    def conclude actor, key
      key = :concluded if key.nil?
      manager = scene_managers[key]
      if manager.state != "Concluded"
        raise NotConclusionError("Cued scene '#{key}' is not a conclusion")
      end
      cue actor, key
    end
  end

end
