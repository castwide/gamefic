# frozen_string_literal: true

module Gamefic
  module Scriptable
    module ScenesV4
      # @deprecated Temporary method that will replace #block
      def _block_v4 klass = Scene::Default, &blk
        scene = klass.hydrate(name, self, &blk)
        script { scene.update_narrative self }
        scene
      end

      def block *args, warned: false, &blk
        if args.first.is_a?(Class)
          _block_v4 args.first, &blk
        else
          name, klass = args
          klass = (klass.is_a?(Class) && klass <= Scene::Default) ? klass : Scene::Default
          Gamefic.logger.warn "Scenes with symbol names are deprecated. Use constants (e.g., `#{name.to_s.cap_first} = block(...)`) instead." unless warned
          script do
            rulebook.scenes.add klass.hydrate(name, klass, &blk).tap { |kls| kls.update_narrative self}, name
            name
          end
          name
        end
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
        script do
          rulebook.scenes
                  .introduction(Scene::Default.hydrate(nil, self) { |scene| scene.on_start(&start) })
        end
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
      def multiple_choice *args, &blk
        if args.first.is_a?(Symbol) || args.length > 1
          Gamefic.logger.warn "Scenes with symbol names are deprecated. Use constants (e.g., `#{name.to_s.cap_first} = multiple_choice(...)`) instead."
          name, options, prompt = args
          options ||= prompt
          prompt ||= 'What is your choice?'
          block name, Scene::MultipleChoice, warned: true do |scene|
            scene.on_start do |_actor, props|
              props.prompt = prompt
              props.options.concat options
            end
            scene.on_finish &blk
          end
          name
        else
          _block_v4 Scene::MultipleChoice, &blk
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
      def yes_or_no name = nil, prompt = 'Answer:', &blk
        if name.nil?
          _block_v4 Scene::YesOrNo, &blk
        else
          Gamefic.logger.warn "Scenes with symbol names are deprecated. Use constants (e.g., `#{name.to_s.cap_first} = yes_or_no(...)`) instead."
          block name, Scene::YesOrNo, warned: true do |scene|
            scene.on_start do |_actor, props|
              props.prompt = prompt
            end
            scene.on_finish &blk
          end
        end
      end
    end
  end
end
