module Gamefic
  module World
    module Scenes
      include Commands
      include Players

      def scenebook
        @scenebook ||= Scenebook.new
      end

      # @todo This is getting a MASSIVE refactor. Think about it.

      # Block a new scene.
      #
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
        scenebook[:default_conclusion] || block(:default_conclusion, rig: Scene::Rig::Conclusion)
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
      # @yieldparam [Gamefic::Actor]
      # @return [Scene]
      def introduction(&proc)
        block(:introduction, on_start: proc, on_finish: ->(actor) { actor.cue default_scene })
      end

      # Introduce a player to the game.
      # This method is typically called by the Engine that manages game execution.
      #
      # @param [Gamefic::Actor]
      # @return [void]
      def introduce(player)
        player.playbooks.push playbook unless player.playbooks.include?(playbook)
        player.scenebooks.push scenebook unless player.scenebooks.include?(scenebook)
        players.push player
        player.cue :introduction
      end

      # Create a multiple-choice scene.
      # The user will be required to make a valid choice to continue.
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
      # @param block [Proc]
      # @yieldparam [Scene]
      # @return [Scene]
      def multiple_choice name, choices = [], prompt = 'What is your choice?', &block
        block name,
              rig: Gamefic::Scene::Rig::MultipleChoice,
              on_start: proc { |_actor, props|
                props.prompt = prompt
                props.options.concat choices
              },
              &block
      end

      # Create a yes-or-no scene.
      # The user will be required to answer Yes or No to continue.
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
      def yes_or_no name, prompt = 'Answer:', &block
        block name,
              rig: Gamefic::Scene::Rig::YesOrNo,
              on_start: proc { |_actor, props|
                props.prompt = prompt
                props.options.concat choices
              },
              &block
      end

      # Create a scene that pauses the game.
      # This scene will execute the specified block and wait for input from the
      # the user (e.g., pressing Enter) to continue.
      #
      # @example
      #   @scene = pause 'Continue' do |actor|
      #     actor.tell "After you continue, you will be prompted for a command."
      #     actor.prepare default_scene
      #   end
      #
      # @param prompt [String, nil] The text to display when prompting the user to continue
      # @param next_cue [Scene, Symbol]
      # @yieldparam [Scene]
      # @return [Scene]
      def pause name, prompt = nil, next_cue = nil, &block
        block name,
              rig: Gamefic::Scene::Rig::Pause,
              on_start: proc { |_actor, props|
                props.prompt = prompt
              },
              on_finish: proc { |actor, _props|
                actor.cue(next_cue || :default_scene)
              },
              &block
      end

      # Create a conclusion.
      # The game (or the character's participation in it) will end after this
      # scene is complete.
      #
      # @example
      #   conclusion :ending do |scene|
      #     scene.on_start do |actor, _props|
      #       actor.tell 'GAME OVER'
      #     end
      #   end
      #
      # @param name [Symbol]
      # @yieldparam [Scene]
      # @return [Scene]
      def conclusion name, &block
        block name,
              rig: Gamefic::Scene::Rig::Conclusion,
              &block
      end
    end
  end
end
