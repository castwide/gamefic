class NotConclusionError < Exception
end

module Gamefic

  module Plot::SceneMount
    # Create a multiple-choice scene.
    # The user will be required to make a valid choice to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::MultipleChoice]
    def multiple_choice key, *choices, &block
      scenes[key] = Scene::MultipleChoice.new
      scenes[key].on_start do |actor, data|
        data.options.push *choices
      end
      scenes[key].on_finish do |actor, data|
        block.call actor, data unless block.nil?
        cue_default actor, key
      end
    end
    
    # Create a yes-or-no scene.
    # The user will be required to answer Yes or No to continue.
    #
    # @yieldparam [Character]
    # @yieldparam [String] "yes" or "no"
    def yes_or_no key, prompt = nil, &block
      scenes[key] = Scene::YesOrNo.new
      unless prompt.nil?
        scenes[key].on_start do |actor, data|
          data.prompt = prompt
        end
      end
      scenes[key].on_finish &block
    end
    
    def question key, prompt = 'What is your answer?', &block
      scenes[key] = Scene::Custom.new
      scenes[key].on_start do |actor, data|
        data.prompt = prompt
      end
      scenes[key].on_finish do |actor, data|
        block.call actor, data unless block.nil?
        cue_default actor, key
      end
    end

    # Create a scene that pauses the game.
    # This scene will execute the specified block and wait for input from the
    # the user (e.g., pressing Enter) to continue.
    #
    # @param key [Symbol] A unique name for the scene.
    # @param prompt [String] The text to display when prompting the user to continue.
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::Base]
    def pause key, prompt = nil, &block
      scenes[key] = Scene::Pause.new
      scenes[key].on_start do |actor, data|
        data.prompt = prompt unless prompt.nil?
        block.call actor, data unless block.nil?
      end
      scenes[key].on_finish do |actor, data|
        cue_default actor, key
      end
    end
    
    # Create a conclusion.
    # The game (or the character's participation in it) will end after this
    # scene is complete.
    #
    # @param key [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::Base]
    def conclusion key, &block
      scenes[key] = Scene::Conclusion.new
      scenes[key].on_start &block
    end
    
    # Create a passive scene.
    # Passive scenes will cue the active scene if another scene
    # has not been prepared or cued.
    #
    # @param [Symbol] A unique name for the scene.
    # @yieldparam [Character]
    # @yieldparam [Scene::Data::Base]
    def passive key, &block
      scenes[key] = Scene::Custom.new
      scenes[key].on_start do |actor, data|
        block.call actor, data
        cue_default actor, key
      end
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
    # @param key [Symbol] A unique name for the scene.
    # @param key [cls] The class of scene to be instantiated.
    # @yieldparam [Scene::Custom] The instantiated scene.
    def scene key, cls = Scene::Custom, &block
      scenes[key] = cls.new
      #block.call scenes[key]
      yield scenes[key] if block_given?
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
      scenes[key] = Scene::MultipleChoice.new
      scenes[key].on_start do |actor, data|
        map.each { |k, v|
          data.map k, v
        }
      end
    end

    private
    
    def cue_default actor, key
      actor.cue :active if actor.scene == key and actor.next_scene.nil?
    end
  end

end
