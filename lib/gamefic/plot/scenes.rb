module Gamefic

  module Plot::Scenes
    def default_scene
      @default_scene ||= Scene::Activity
    end

    def default_conclusion
      @default_conclusion ||= Scene::Conclusion
    end

    # Add a block to be executed when a player is added to the game.
    # Each Plot can only have one introduction. Subsequent calls will
    # overwrite the existing one.
    #
    # @example Welcome the player to the game
    #   introduction do |actor|
    #     actor.tell "Welcome to the game!"
    #   end
    #
    # @yieldparam [Gamefic::Character]
    def introduction (&proc)
      @introduction = proc
    end

    # Introduce a player to the game.
    # This method is typically called by the Engine that manages game execution.
    #
    # @param [Gamefic::Character]
    def introduce(player)
      player.playbook = playbook
      player.cue default_scene
      puts "Player should be added here"
      p_players.push player
      @introduction.call(player) unless @introduction.nil?
    end

    # Create a multiple-choice scene.
    # The user will be required to make a valid choice to continue.
    #
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::Data::MultipleChoice]
    def multiple_choice *choices, &block
      s = Scene::MultipleChoice.subclass do |actor, scene|
        scene.options.concat choices
        scene.on_finish &block
      end
      scene_classes.push s
      s
    end
    
    # Create a yes-or-no scene.
    # The user will be required to answer Yes or No to continue.
    #
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::YesOrNo]
    def yes_or_no prompt = nil, &block
      s = Scene::YesOrNo.subclass do |actor, scene|
        scene.prompt = prompt
        scene.on_finish &block
      end
      scene_classes.push s
      s
    end

    # Create a scene with custom processing on user input.
    #
    # @example Echo the user's response
    #   @scene = question 'What do you say?' do |actor, scene|
    #     actor.tell "You said #{scene.input}"
    #   end
    #
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::YesOrNo]
    def question prompt = 'What is your answer?', &block
      s = Scene::Custom.subclass do |actor, scene|
        scene.prompt = prompt
        scene.on_finish &block
      end
      scene_classes.push s
      s
    end

    # Create a scene that pauses the game.
    # This scene will execute the specified block and wait for input from the
    # the user (e.g., pressing Enter) to continue.
    #
    # @param prompt [String] The text to display when prompting the user to continue.
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::Pause]
    def pause prompt = nil, &block
      s = Scene::Pause.subclass do |actor, scene|
        scene.prompt = prompt unless prompt.nil?
        block.call(actor, scene) unless block.nil?
      end
      scene_classes.push s
      s
    end
    
    # Create a conclusion.
    # The game (or the character's participation in it) will end after this
    # scene is complete.
    #
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::Conclusion]
    def conclusion &block
      s = Scene::Conclusion.subclass &block
      scene_classes.push s
      s
    end
    
    # Create a custom scene.
    #
    # Custom scenes should always specify the next scene to be cued or
    # prepared. If not, the scene will get repeated on the next turn.
    #
    # This method creates a Scene::Custom by default. You can customize other
    # scene types by specifying the class to create.
    #
    # @example Ask the user for a name
    #   @scene = custom do |scene|
    #     data.prompt = "What's your name?"
    #     scene.on_finish do |actor, data|
    #       actor.name = data.input
    #       actor.tell "Hello, #{actor.name}!"
    #       actor.cue :active
    #     end
    #   end
    #
    # @param cls [Class] The class of scene to be instantiated.
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Scene::Custom] The instantiated scene.
    def custom cls = Scene::Custom, &block
      s = cls.subclass &block
      scene_classes.push s
      s
    end

    # Choose a new scene based on a list of options.
    # This is a specialized type of multiple-choice scene that determines
    # which scene to cue based on a Hash of choices and scene keys.
    #
    # @example Select a scene
    #   scene_one = pause do |actor|
    #     actor.tell "You went to scene one"
    #   end
    #
    #   scene_two = pause do |actor|
    #     actor.tell "You went to scene two"
    #   end
    #
    #   select_one_or_two = multiple_scene "One" => scene_one, "Two" => scene_two
    #
    #   introduction do |actor|
    #     actor.cue select_one_or_two # The actor will be prompted to select "one" or "two" and get sent to the corresponding scene
    #   end
    #
    # @example Customize options
    #   scene_one = pause # do...
    #   scene_two = pause # do...
    #
    #   # Some event in the game sets actor[:can_go_to_scene_two] to true
    #
    #   select_one_or_two = multiple_scene do |actor, scene|
    #     scene.map "Go to scene one", scene_one
    #     scene.map "Go to scene two", scene_two if actor[:can_go_to_scene_two]
    #   end
    #
    # @param map [Hash] A Hash of options and associated scenes.
    # @yieldparam [Gamefic::Character]
    # @yieldparam [Gamefic::Scene::MultipleScene]
    def multiple_scene map = {}, &block
      s = Scene::MultipleScene.subclass do |actor, scene|
        map.each_pair { |k, v|
          scene.map k, v
        }
        block.call actor, scene unless block.nil?
      end
      scene_classes.push s
      s
    end

    def scene_classes
      @scene_classes ||= []
    end
  end

end
