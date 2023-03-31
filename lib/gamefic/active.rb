# frozen_string_literal: true

require 'set'

module Gamefic
  class NotConclusionError < RuntimeError; end

  # The Active module gives entities the ability to perform actions and
  # participate in scenes. The Actor class, for example, is an Entity
  # subclass that includes this module.
  #
  module Active
    include Logging

    # The scene in which the entity is currently participating.
    #
    # @return [Gamefic::Scene]
    attr_reader :scene

    # @return [Symbol]
    attr_reader :next_scene_name

    # @return [Hash]
    attr_reader :next_scene_data

    # The prompt for the previous scene.
    #
    # @return [String]
    attr_accessor :last_prompt

    # The input for the previous scene.
    #
    # @return [String]
    attr_accessor :last_input

    # The playbooks that will be used to perform commands.
    #
    # @return [Array<Gamefic::World::Playbook>]
    def playbooks
      @playbooks ||= []
    end

    # The scenebooks that will be used to participate in scenes.
    #
    # @return [Array<Gamefic::World::Scenebook>]
    def scenebooks
      @scenebooks ||= []
    end

    # An array of commands waiting to be executed.
    #
    # @return [Array<String>]
    def queue
      @queue ||= []
    end

    # A hash of values representing the state of a performing entity.
    #
    # @todo Does this really need to be here? It might make more sense
    #   to move it out to the scene or something.
    #
    # @return [Hash{Symbol => Object}]
    def state
      @state ||= {}
    end

    # @todo Same applies here as state. Maybe stop doing this and handle
    #   it in the scene.
    def output
      @output ||= {}
    end

    # Send a message to the entity.
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      if buffer_stack > 0
        append_buffer format(message)
      else
        super
      end
    end

    # Send a message to the Character as raw text.
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      if buffer_stack > 0
        append_buffer message
      else
        super
      end
    end

    # Perform a command.
    #
    # The command's action will be executed immediately regardless of the
    # entity's state.
    #
    # @example Send a command as a string
    #   character.perform "take the key"
    #
    # @param command [String]
    # @return [void]
    def perform(command)
      dispatchers.push Dispatcher.dispatch(self, command)
      proceed
      dispatchers.pop
    end

    # Quietly perform a command.
    # This method executes the command exactly as #perform does, except it
    # buffers the resulting output instead of sending it to the user.
    #
    # @param command [String]
    # @return [String] The output that resulted from performing the command.
    def quietly(command)
      dispatchers.push Dispatcher.dispatch(self, command)
      result = proceed quietly: true
      dispatchers.pop
      result
    end

    # Perform an action.
    # This is functionally identical to the `perform` method, except the
    # action must be declared as a verb with a list of parameters. Use
    # `perform` if you need to parse a string as a command.
    #
    # The command will be executed immediately regardless of the entity's
    # state.
    #
    # @example
    #   character.execute :take, @key
    #
    # @param verb [Symbol]
    # @param params [Array]
    # @params quietly [Boolean]
    # @return [Gamefic::Action]
    def execute(verb, *params, quietly: false)
      dispatchers.push Dispatcher.dispatch_from_params(self, verb, params)
      proceed quietly: quietly
      dispatchers.pop
    end

    # Proceed to the next Action in the current stack.
    # This method is typically used in Action blocks to cascade through
    # multiple implementations of the same verb.
    #
    # @example Proceed through two implementations of a verb
    #   introduction do |actor|
    #     actor[:has_eaten] = false # Initial value
    #   end
    #
    #   respond :eat do |actor|
    #     actor.tell "You eat something."
    #     actor[:has_eaten] = true
    #   end
    #
    #   respond :eat do |actor|
    #     # This version will be executed first because it was implemented last
    #     if actor[:has_eaten]
    #       actor.tell "You already ate."
    #     else
    #       actor.proceed # Execute the previous implementation
    #     end
    #   end
    #
    # @param quietly [Boolean] If true, return the action's output instead of appending it to #messages
    # @return [String, nil]
    def proceed quietly: false
      a = dispatchers&.last.next
      return if a.nil?

      prepare_buffer quietly
      a.execute
      flush_buffer quietly
    end

    # Cue a scene to start in the next turn.
    #
    # @param scene [Scene, Symbol]
    # @param data [Hash] Extra data to pass to the scene's props.
    # @return [Symbol]
    def cue scene, **data
      logger.warn "Overwriting existing cue `#{@next_scene_name}` with `#{scene.to_sym}`" if @next_scene_name

      @next_scene_name = select_scene(scene)
      raise ArgumentError, "Invalid scene `#{scene}`" unless @next_scene_name

      @next_scene_data = data
      @next_scene_name
    end
    alias prepare cue

    # Cue a conclusion. This method works like #cue, except it will raise a
    # NotConclusionError if the scene is not a Scene::Conclusion.
    #
    # @param new_scene [Class<Scene::Base>]
    # @oaram data [Hash] Additional scene data
    def conclude new_scene, **data
      raise NotConclusionError unless new_scene.rig <= Scene::Conclusion

      cue new_scene, **data
    end

    # True if the character is in a conclusion.
    #
    # @return [Boolean]
    def concluded?
      !scene.nil? && scene.kind_of?(Scene::Conclusion)
    end

    def accessible?
      false
    end

    def inspect
      to_s
    end

    # Track the entity's performance of a scene.
    #
    def entered scene
      klass = (scene.is_a?(Gamefic::Scene::Base) ? scene.class : scene)
      entered_scenes.add klass
    end

    # Determine whether the entity has performed the specified scene.
    #
    # @return [Boolean]
    def entered? scene
      klass = (scene.kind_of?(Gamefic::Scene::Base) ? scene.class : scene)
      entered_scenes.include?(klass)
    end

    private

    def prepare_buffer quietly
      if quietly
        if buffer_stack == 0
          @buffer = ""
        end
        set_buffer_stack(buffer_stack + 1)
      end
    end

    def flush_buffer quietly
      if quietly
        set_buffer_stack(buffer_stack - 1)
        @buffer
      end
    end

    # @return [Set<Gamefic::Scene::Base>]
    def entered_scenes
      @entered_scenes ||= Set.new
    end

    def buffer_stack
      @buffer_stack ||= 0
    end

    def set_buffer_stack num
      @buffer_stack = num
    end

    # @return [String]
    def buffer
      @buffer ||= ''
    end

    def append_buffer str
      @buffer += str
    end

    def clear_buffer
      @buffer = ''
    end

    def dispatchers
      @dispatchers ||= []
    end

    # @param scene [Scene, Symbol]
    # @return [Symbol]
    def select_scene scene
      scene.is_a?(Scene) ? select_scene_by_instance(scene) : select_scene_by_name(scene)
    end

    def select_scene_by_instance scene
      scenebooks.reverse.each do |sb|
        return scene.name if sb.scenes.include?(sb)
      end
      nil
    end

    def select_scene_by_name name
      scenebooks.reverse.each do |sb|
        return name if sb.scene?(name)
      end
      nil
    end
  end
end
