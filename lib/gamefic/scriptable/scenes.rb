# frozen_string_literal: true

require 'set'

module Gamefic
  module Scriptable
    module Scenes
      attr_reader :default_scene, :default_conclusion

      def select_default_scene(klass)
        scene_classes.add klass
        @default_scene = klass
      end

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
        scene_classes.select(&:name)
                     .each_with_object(named_scenes.clone) { |klass, hash| hash[klass] = klass }
      end

      def block name = nil, klass = Scene::Default, &blk
        scene = Class.new(klass, &blk)
        named_scenes[name] = scene if name
        scene_classes.add scene
        name
      end

      def scene name, klass
        named_scenes[name] = klass if name
        scene_classes.add klass
      end

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
      # @return [Symbol]
      def introduction(&start)
        introductions.push start
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
      def multiple_choice name = nil, &blk
        block name, Scene::MultipleChoice, &blk
      end

      def active_choice name = nil, &blk
        block name, Scene::ActiveChoice, &blk
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
      def yes_or_no(name = nil, &blk)
        block name, Scene::YesOrNo, &blk
      end

      def pause(name = nil, &blk)
        block name, Scene::Pause, &blk
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
      def conclusion(name = nil, &blk)
        block name, Scene::Conclusion do |scene|
          scene.on_start(&blk)
        end
      end
    end
  end
end
