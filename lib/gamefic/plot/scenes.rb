module Gamefic

  module Plot::Scenes
    def default_scene
      @default_scene ||= Scene::Active.new(self)
    end

    def default_conclusion
      @default_conclusion ||= Scene::Conclusion.new
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
    # @yieldparam [Character]
    def introduction (&proc)
      @introduction = proc
    end

    # Introduce a player to the game.
    # This method is typically called by the Engine that manages game execution.
    def introduce(player)
      player.playbook = playbook
      player.cue default_scene
      p_players.push player
      @introduction.call(player) unless @introduction.nil?
    end

    # Create a multiple-choice scene.
    # The user will be required to make a valid choice to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::MultipleChoice]
    def multiple_choice *choices, &block
      s = Scene::MultipleChoice.new
      s.on_start do |actor, data|
        data.options.clear
        data.options.push *choices
      end
      s.on_finish &block
      s
    end
    
    # Create a yes-or-no scene.
    # The user will be required to answer Yes or No to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [String] "yes" or "no"
    def yes_or_no prompt = nil, &block
      s = Scene::YesOrNo.new
      unless prompt.nil?
        s.on_start do |actor, data|
          data.prompt = prompt
        end
      end
      s.on_finish do |actor, data|
        block.call actor, data unless block.nil?
        actor.cue default_scene if actor.scene == s and actor.next_scene.nil?
      end
      s
    end
    
    def question prompt = 'What is your answer?', &block
      s = Scene::Custom.new
      s.on_start do |actor, data|
        data.prompt = prompt
      end
      s.on_finish &block
      s
    end

    # Create a scene that pauses the game.
    # This scene will execute the specified block and wait for input from the
    # the user (e.g., pressing Enter) to continue.
    #
    # @param prompt [String] The text to display when prompting the user to continue.
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::Base]
    def pause prompt = nil, &block
      s = Scene::Pause.new
      s.on_start do |actor, data|
        data.prompt = prompt unless prompt.nil?
        block.call actor, data unless block.nil?
      end
      s.on_finish do |actor, data|
        #actor.cue :active if actor.scene == key and actor.next_scene.nil?
        actor.cue default_scene if actor.scene == s and actor.next_scene.nil?
      end
      s
    end
    
    # Create a conclusion.
    # The game (or the character's participation in it) will end after this
    # scene is complete.
    #
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::Base]
    def conclusion &block
      s = Scene::Conclusion.new
      s.on_start &block
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
    #   scene :ask_for_name do |scene|
    #     scene.on_start do |actor, data|
    #       data.prompt = "What's your name?"
    #     end
    #     scene.on_finish do |actor, data|
    #       actor.name = data.input
    #       actor.tell "Hello, #{actor.name}!"
    #       actor.cue :active
    #     end
    #   end
    #
    # @example Customize the prompt for a MultipleChoice scene
    #   scene :ask_for_choice, Scene::MultipleChoice do |scene|
    #     scene.on_start do |actor, data|
    #       data.options.push 'red', 'green', 'blue'
    #       data.prompt = "Which color?"
    #     end
    #     scene.on_finish do |actor, data|
    #       actor.tell "You chose #{data.selection}"
    #       actor.cue :active
    #     end
    #   end
    #
    # @param cls [Class] The class of scene to be instantiated.
    # @yieldparam [Scene::Custom] The instantiated scene.
    def scene cls = Scene::Custom, &block
      s = cls.new
      yield s if block_given?
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
    # @param map [Hash] A Hash of options and associated scene keys.
    def multiple_scene map = {}
      s = Scene::MultipleScene.new
      s.on_start do |actor, data|
        map.each { |k, v|
          data.map k, v
        }
      end
      yield(s) if block_given?
      s
    end
  end

end
