module Gamefic
  module World
    module Scenes
      include Books
      include Commands
      include Players

      # @return [Array<Take>]
      def takes
        @takes ||= []
      end

      # Block a new scene.
      #
      # @example Prompt the player for a name
      #   block :ask_for_name do
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
      # @raise [NameError] if a scene with the given name already exists
      #
      # @param name [Symbol, nil]
      # @param rig [Class<Scene::Rig::Base>]
      # @param type [String, nil]
      # @param on_start [Proc, nil]
      # @param on_finish [Proc, nil]
      # @param block [Proc]
      # @yieldparam [Scene]
      # @return [Scene]
      def block name, rig: Scene::Rig::Base, type: nil, on_start: nil, on_finish: nil, **rig_opts, &block
        scenebook.block(name, rig: rig, type: type, on_start: on_start, on_finish: on_finish, **rig_opts, &block)
      end
      alias custom block

      # @return [Scene]
      def default_scene
        scenebook[:default_scene] || block(:default_scene, rig: Scene::Rig::Activity)
      end

      # @return [Scene]
      def default_conclusion
        scenebook[:default_conclusion] ||
          block(:default_conclusion,
                rig: Scene::Rig::Conclusion,
                on_start: proc { |actor, _props|
                })
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
      # @param pause [Boolean] Pause before the first action if true
      # @yieldparam [Gamefic::Actor]
      # @yieldparam [Scene::Props::Base]
      # @return [Scene]
      def introduction(rig: Gamefic::Rig::Activity, &start)
        block :introduction,
              rig: rig,
              on_start: proc { |actor, props|
                start&.call(actor, props)
              }
      end

      # Introduce a player to the game.
      # This method is typically called by the Engine that manages game execution.
      #
      # @param [Gamefic::Actor]
      # @return [void]
      def introduce(player)
        @introduced = true
        player.playbooks.push playbook unless player.playbooks.include?(playbook)
        player.scenebooks.push scenebook unless player.scenebooks.include?(scenebook)
        players.push player
        player.select_cue :introduction, default_scene
      end

      def introduced?
        @introduced ||= false
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
      # @return [Scene]
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
      #   @scene = yes_or_no 'What is your answer?' do |actor, scene|
      #     if scene.yes?
      #       actor.tell "You said yes."
      #     else
      #       actor.tell "You said no."
      #     end
      #   end
      #
      # @param name [Symbol]
      # @param prompt [String, nil]
      # @yieldparam [Scene]
      # @return [Scene]
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
      #   @scene = pause :pause_scene do |actor|
      #     actor.tell "After you continue, you will be prompted for a command."
      #   end
      #
      # @param name [Symbol]
      # @param prompt [String, nil] The text to display when prompting the user to continue
      # @param next_cue [Scene, Symbol, nil]
      # @yieldparam [Actor]
      # @return [Scene]
      def pause name, prompt: 'Press enter to continue...', next_cue: nil, &start
        block name,
              rig: Gamefic::Rig::Pause,
              on_start: proc { |actor, props|
                props.prompt = prompt if prompt
                actor.cue(next_cue || :default_scene)
                start.call(actor)
              }
      end

      # Create a conclusion.
      # The game (or the character's participation in it) will end after this
      # scene is complete.
      #
      # @example
      #   conclusion :ending do |scene|
      #     scene.on_start do |actor, _props|
      #       actor.tell 'GAME OVER'
      #       actor.tell 'Press Enter to exit the game.'
      #     end
      #     scene.on_finish do |_actor, _props|
      #       exit
      #     end
      #   end
      #
      # @param name [Symbol]
      # @yieldparam [Scene]
      # @return [Scene]
      def conclusion name, &start
        block name,
              rig: Gamefic::Rig::Conclusion,
              on_start: proc { |actor, props|
                start&.call(actor, props)
              }
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
        scenebook.on_ready &block
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
        scenebook.on_player_ready &block
      end

      # Add a block to be executed after the Plot is finished updating a turn.
      #
      def on_update &block
        scenebook.on_update &block
      end

      # Add a block to be executed for each player at the end of a turn.
      #
      # @yieldparam [Gamefic::Actor]
      def on_player_update &block
        scenebook.on_player_update &block
      end

      # @yieldparam [Actor]
      # @return [Proc]
      def on_player_conclude &block
        scenebook.on_player_conclude &block
      end

      # @yieldparam [Actor]
      # @yieldparam [Hash]
      # @return [Proc]
      def on_player_output &block
        scenebook.on_player_output &block
      end

      def ready
        scenebook.ready_blocks.each(&:call)
        prepare_takes
        start_takes
      end

      def update
        finish_takes
        players.each do |plyr|
          scenebook.player_update_blocks.each { |blk| blk.call plyr }
        end
        scenebook.update_blocks.each(&:call)
      end

      private

      def prepare_takes
        takes.replace(players.map do |pl|
          pl.start_cue default_scene
        end)
      end

      def start_takes
        takes.each do |take|
          scenebook.run_player_ready_blocks take.actor
          take.start
          scenebook.run_player_output_blocks take.actor, take.output
        end
      end

      def finish_takes
        takes.each do |take|
          take.finish
          next if take.cancelled? || take.scene.type != 'Conclusion'

          exeunt take.actor
        end
        takes.clear
      end
    end
  end
end
