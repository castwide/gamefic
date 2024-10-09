# frozen_string_literal: true

module Gamefic
  module Scriptable
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
      # @param klass [Class<Scene::Default>]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @param block [Proc]
      # @yieldparam [Scene]
      # @return [Symbol]
      def block name, klass = Scene::Default, &blk
        rulebook.scenes.add klass.bind(self, &blk), name
        name
      end

      def preface name, klass = Scene::Activity, &start
        Logging.logger.warn "#{caller.first ? "#{caller.first}: " : ''}`proxy` is deprecated. Use `pick` or `pick!` instead."
        rulebook.scenes.add(klass.bind(self) do |scene|
          scene.on_start &start
        end, name)
        name
      end
      alias precursor preface

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
      # @yieldparam [Gamefic::Actor]
      # @yieldparam [Props::Default]
      # @return [Symbol]
      def introduction(&start)
        rulebook.scenes
                .introduction(Scene::Default.bind(self) { |scene| scene.on_start(&start) })
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
      def multiple_choice name, choices = [], prompt = 'What is your choice?', &blk
        block name, Scene::MultipleChoice do |scene|
          scene.on_start do |_actor, props|
            props.prompt = prompt
            props.options.concat choices
          end
          scene.on_finish &blk
        end
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
      def yes_or_no name, prompt = 'Answer:', &blk
        block name, Scene::YesOrNo do |scene|
          scene.on_start do |_actor, props|
            props.prompt = prompt
          end
          scene.on_finish &blk
        end
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
        block name, Scene::Pause do |scene|
          scene.on_start do |_actor, props|
            props.prompt = prompt if prompt
          end
          scene.on_start &start
        end
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
        block name, Scene::Conclusion do |scene|
          scene.on_start &start
        end
      end

      # @return [Array<Symbol>]
      def scenes
        rulebook.scenes.names
      end

      # @param name [Symbol]
      # @return [Scene::Default, nil]
      def scene(name)
        rulebook.scenes[name]
      end
    end
  end
end
