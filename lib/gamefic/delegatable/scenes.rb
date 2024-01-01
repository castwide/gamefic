# frozen_string_literal: true

module Gamefic
  module Delegatable
    # Scriptable methods related to creating scenes.
    #
    module Scenes
      # Block a new scene.
      #
      # @example Prompt the player for a name
      #   block :name_of_scene do |scene|
      #     # The scene's start occurs before the user gets prompted for input
      #     scene.on_start do |actor, props|
      #       props.prompt = 'What's your name?'
      #     end
      #
      #     # The scene's finish is where you can process the user's input
      #     scene.on_finish do |actor, props|
      #       if props.input.empty?
      #         # You can use recue to start the scene again
      #         actor.recue
      #       else
      #         actor.tell "Hello, #{props.input}!"
      #       end
      #     end
      #   end
      #
      # @param name [Symbol]
      # @param rig [Class<Rig::Default>]
      # @param type [String, nil]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @param block [Proc]
      # @yieldparam [Scene]
      # @return [Symbol]
      def block name, rig: Rig::Default, type: nil, on_start: nil, on_finish: nil, &block
        rulebook.scenes.add Scene.new(name, rulebook.narrative, rig: rig, type: type, on_start: on_start, on_finish: on_finish, &block)
        name
      end
      alias scene block

      # Add a block to be executed when a player is added to the game.
      # Each Plot should only have one introduction.
      #
      # @example Welcome the player to the game
      #   introduction do |actor|
      #     actor.tell "Welcome to the game!"
      #   end
      #
      # @raise [ArgumentError] if an introduction already exists
      #
      # @param pause [Boolean] Pause before the first action if true
      # @yieldparam [Gamefic::Actor]
      # @yieldparam [Props::Default]
      # @return [Symbol]
      def introduction(rig: Gamefic::Rig::Activity, &start)
        rulebook.scenes.introduction Scene.new nil,
                                               rulebook.narrative,
                                               rig: rig,
                                               on_start: proc { |actor, _props|
                                                 instance_exec(actor, &start)
                                               }
      end

      # Create a multiple-choice scene.
      # The user will be required to make a choice to continue. The scene
      # will restart if the user input is not a valid choice.
      #
      # @example
      #   multiple_choice :go_somewhere, ['Go to work', 'Go to school'] do |actor, props|
      #     # Assuming the user selected the first choice:
      #     props.selection #=> 'Go to work'
      #     props.index     #=> 0
      #     props.number    #=> 1
      #   end
      #
      # @param name [Symbol]
      # @param choices [Array<String>]
      # @param prompt [String, nil]
      # @param proc [Proc]
      # @yieldparam [Actor]
      # @yieldparam [Props::MultipleChoice]
      # @return [Symbol]
      def multiple_choice name, choices = [], prompt = 'What is your choice?', &block
        block name,
              rig: Gamefic::Rig::MultipleChoice,
              on_start: proc { |_actor, props|
                props.prompt = prompt
                props.options.concat choices
              },
              on_finish: block
      end

      # Create a yes-or-no scene.
      # The user will be required to answer Yes or No to continue. The scene
      # will restart if the user input is not a valid choice.
      #
      # @example
      #   yes_or_no :answer_scene, 'What is your answer?' do |actor, props|
      #     if props.yes?
      #       actor.tell "You said yes."
      #     else
      #       actor.tell "You said no."
      #     end
      #   end
      #
      # @param name [Symbol]
      # @param prompt [String, nil]
      # @yieldparam [Actor]
      # @yieldparam [Props::YesOrNo]
      # @return [Symbol]
      def yes_or_no name, prompt = 'Answer:', &block
        block name,
              rig: Gamefic::Rig::YesOrNo,
              on_start: proc { |_actor, props|
                props.prompt = prompt
              },
              on_finish: block
      end

      # Create a scene that pauses the game.
      # This scene will execute the specified block and wait for input from the
      # the user (e.g., pressing Enter) to continue.
      #
      # @example
      #   pause :wait do |actor|
      #     actor.tell "After you continue, you will be prompted for a command."
      #   end
      #
      # @param name [Symbol]
      # @param prompt [String, nil] The text to display when prompting the user to continue
      # @yieldparam [Actor]
      # @return [Symbol]
      def pause name, prompt: 'Press enter to continue...', &start
        block name,
              rig: Gamefic::Rig::Pause,
              on_start: proc { |actor, props|
                props.prompt = prompt if prompt
                instance_exec(actor, props, &start)
              }
      end

      # Create a conclusion.
      # The game (or the character's participation in it) will end after this
      # scene is complete.
      #
      # @example
      #   conclusion :ending do |actor|
      #     actor.tell 'GAME OVER'
      #   end
      #
      # @param name [Symbol]
      # @yieldparam [Actor]
      # @return [Symbol]
      def conclusion name, &start
        block name,
              rig: Gamefic::Rig::Conclusion,
              on_start: start
      end

      def scenes
        rulebook.scenes.names
      end
    end
  end
end
