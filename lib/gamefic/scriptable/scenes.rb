# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating scenes.
    #
    module Scenes
      # Block a new scene.
      #
      # @example Prompt the player for a name
      #   block :ask_for_name do |scene|
      #     # The scene's start occurs before the user gets prompted for input
      #     scene.on_start do |actor, props|
      #       props.prompt = 'What's your name?'
      #     end
      #
      #     # The scene's finish is where you can process the input
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
        # staged_start = proc { |actor, props| stage actor, props, &on_start }
        # staged_finish = proc { |actor, props| stage actor, props, &on_finish }
        # staged_block = proc { |scene| stage scene, &block }
        scenebook.add Scene.new(name, method(:stage), rig: rig, type: type, on_start: on_start, on_finish: on_finish, &block)
        name
      end

      # @return [Scene]
      # def default_scene
      #   @default_scene ||= block(rig: Rig::Activity)
      # end

      # @return [Scene]
      # def default_conclusion
      #   @default_conclusion ||=
      #     block(:default_conclusion,
      #           rig: Rig::Conclusion,
      #           on_start: proc { |actor, _props|
      #                     })
      # end

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
        @introduction ||= Scene.new nil,
                                    method(:stage),
                                    rig: rig,
                                    on_start: proc { |actor, props|
                                      start&.call(actor, props)
                                    }
      end

      # Create a multiple-choice scene.
      # The user will be required to make a choice to continue. The scene
      # will restart if the user input is not a valid choice.
      #
      # @example
      #   multiple_choice :go_somewhere, ['Go to work', 'Go to school'] do |scene|
      #     scene.on_finish do |actor, props|
      #       # Assuming the user selected the first choice:
      #       props.selection # => 'Go to work'
      #       props.index     # => 0
      #       props.number    # => 1
      #     end
      #   end
      #
      # @param name [Symbol]
      # @param choices [Array<String>]
      # @param prompt [String, nil]
      # @param proc [Proc]
      # @yieldparam [Scene]
      # @return [Symbol]
      def multiple_choice name, choices = [], prompt = 'What is your choice?', &proc
        block name,
              rig: Gamefic::Rig::MultipleChoice,
              on_start: proc { |_actor, props|
                props.prompt = prompt
                props.options.concat choices
              },
              &proc
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
      # @yieldparam [Scene]
      # @return [Symbol]
      def yes_or_no name, prompt = 'Answer:', &proc
        block name,
              rig: Gamefic::Rig::YesOrNo,
              on_start: proc { |_actor, props|
                props.prompt = prompt
              },
              &proc
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
      # @param next_cue [Scene, Symbol, nil]
      # @yieldparam [Actor]
      # @return [Symbol]
      def pause name, prompt: 'Press enter to continue...', next_cue: nil, &start
        block name,
              rig: Gamefic::Rig::Pause,
              on_start: proc { |actor, props|
                props.prompt = prompt if prompt
                start&.call actor, props
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
      # @yieldparam [Scene]
      # @return [Symbol]
      def conclusion name, &start
        block name,
              rig: Gamefic::Rig::Conclusion,
              on_start: start
      end

      def scenes
        scenebook.names
      end

      # Add a block to be executed on preparation of every turn.
      #
      # @example Increment a turn counter
      #   turn = 0
      #   on_ready do
      #     turn += 1
      #   end
      #
      def on_ready &block
        scenebook.on_ready(&block)
      end

      # Add a block to be executed for each player at the beginning of a turn.
      #
      # @example Tell the player how many turns they've played.
      #   on_player_ready do |player|
      #     player[:turns] ||= 1
      #     player.tell "Turn #{player[:turns]}"
      #     player[:turns] += 1
      #   end
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_ready &block
        scenebook.on_player_ready(&block)
      end

      # Add a block to be executed after the Plot is finished updating a turn.
      #
      def on_update &block
        scenebook.on_update(&block)
      end

      # Add a block to be executed for each player at the end of a turn.
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_update &block
        scenebook.on_player_update(&block)
      end

      # @yieldparam [Actor]
      # @return [Proc]
      def on_player_conclude &block
        scenebook.on_player_conclude(&block)
      end

      # @yieldparam [Actor]
      # @yieldparam [Hash]
      # @return [Proc]
      def on_player_output &block
        scenebook.on_player_output(&block)
      end
    end
  end
end
