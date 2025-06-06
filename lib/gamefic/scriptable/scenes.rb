# frozen_string_literal: true

require 'set'

module Gamefic
  module Scriptable
    module Scenes
      # @return [Scene::Base]
      attr_reader :default_scene

      # @return [Scene::Conclusion]
      attr_reader :default_conclusion

      # @param [Scene::Base]
      def select_default_scene(klass)
        scene_classes.add klass
        @default_scene = klass
      end

      # @param [Scene::Conclusion]
      def select_default_conclusion(klass)
        scene_classes.add klass
        @default_conclusion = klass
      end

      def named_scenes
        @named_scenes ||= {}
      end

      def scene_classes
        @scene_classes ||= Set.new
      end

      def scene_classes_map
        scene_classes.each_with_object(named_scenes.clone) { |klass, hash| hash[klass] = klass }
      end

      def scenes
        scene_classes_map.values.uniq
      end

      def block(scene, name = nil)
        named_scenes[name] = scene if name
        scene_classes.add scene
        scene
      end
      alias scene block

      # @return [Array<Proc>]
      def introductions
        @introductions ||= []
      end

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
      # @yieldreceiver [Object<self>]
      # @return [void]
      def introduction(&start)
        introductions.push start
      end

      # Create a multiple-choice scene.
      # The user will be required to make a choice to continue. The scene
      # will restart if the user input is not a valid choice.
      #
      # @example
      #   multiple_choice :go_somewhere, do
      #     on_start do |actor, props|
      #       props.options.push 'Go to work', 'Go to school'
      #     end
      #
      #     on_finish do |actor, props|
      #       # Assuming the user selected the first choice:
      #       props.selection #=> 'Go to work'
      #       props.index     #=> 0
      #       props.number    #=> 1
      #     end
      #   end
      #
      # @param name [Symbol, nil]
      # @yieldreceiver [Class<Scene::MultipleChoice>]
      # @return [Class<Scene::MultipleChoice>]
      def multiple_choice(name = nil, &block)
        self.block Class.new(Scene::MultipleChoice, &block), name
      end

      # Create a yes-or-no scene.
      # The user will be required to answer Yes or No to continue. The scene
      # will restart if the user input is not a valid choice.
      #
      # @example
      #   yes_or_no :answer_scene do
      #     on_start do |actor, props|
      #       actor.tell 'Yes or no?'
      #     end
      #
      #     on_finish do |actor, props|
      #       if props.yes?
      #         actor.tell 'You said yes.'
      #       else
      #         actor.tell 'You said no.'
      #       end
      #     end
      #   end
      #
      # @param name [Symbol, nil]
      # @return [Class<Scene::YesOrNo>]
      def yes_or_no(name = nil, &block)
        self.block Class.new(Scene::YesOrNo, &block), name
      end

      # Create an active choice scene.
      #
      # @param name [Symbol, nil]
      # @return [Class<Scene::ActiveChoice>]
      def active_choice(name = nil, &block)
        self.block Class.new(Scene::ActiveChoice, &block), name
      end

      # Create a pause.
      # The block will be executed at the start of the scene and the player
      # will be prompted to press enter to continue.
      #
      # @param name [Symbol, nil]
      # @yieldparam [Actor]
      # @yieldparam [Props::Default]
      # @yieldreceiver [Object<self>]
      # @return [Class<Scene::Pause>]
      def pause(name = nil, &block)
        self.block(Class.new(Scene::Pause) do
          on_start(&block)
        end, name)
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
      # @param name [Symbol, nil]
      # @yieldparam [Actor]
      # @yieldparam [Props::Default]
      # @yieldreceiver [Object<self>]
      # @return [Class<Scene::Conclusion>]
      def conclusion(name = nil, &block)
        self.block(Class.new(Scene::Conclusion) do
          on_start(&block)
        end, name)
      end
    end
  end
end
