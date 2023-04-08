# frozen_string_literal: true

require 'set'
require 'gamefic/active/cue'

module Gamefic
  class NotConclusionError < RuntimeError; end

  # The Active module gives entities the ability to perform actions and
  # participate in scenes. The Actor class, for example, is an Entity
  # subclass that includes this module.
  #
  module Active
    include Logging

    # The cue that will be used to create a scene at the beginning of the next
    # turn.
    #
    # @return [Active::Cue, nil]
    attr_reader :next_cue

    # The prompt for the previous scene.
    #
    # @return [String]
    attr_accessor :last_prompt

    # The input for the previous scene.
    #
    # @return [String]
    attr_accessor :last_input

    # The playbooks that will be used to perform commands. Every plot and
    # subplot has its own playbook.
    #
    # @return [Array<Gamefic::World::Playbook>]
    def playbooks
      @playbooks ||= []
    end

    # The scenebooks that will be used to participate in scenes. Every plot and
    # subplot has its own scenebook.
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

    # A hash of data that will be sent to the user. The output is typically
    # sent after a scene has started and before the user is prompted for input.
    #
    # @return [Hash]
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

    # Send a message to the entity as raw text.
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
    # The command's action will be executed immediately, regardless of the
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
      a = dispatchers&.last&.next
      prepare_buffer quietly
      a&.execute
      flush_buffer quietly
    end

    # Cue a scene to start in the next turn.
    #
    # @raise [ArgumentError] if the scene is not valid
    #
    # @param scene [Symbol]
    # @param context [Hash] Extra data to pass to the scene's props
    # @return [Cue]
    def cue scene, **context
      return @next_cue if @next_cue&.scene == scene && @next_cue&.context == context

      logger.warn "Overwriting existing cue `#{@next_cue.scene}` with `#{scene}`" if @next_cue

      @next_cue = Cue.new(scene, **context)
    end
    alias prepare cue

    # Start a take from the next cue. Start the default cue if a next one has
    # not been selected.
    #
    # @todo Is this note still valid?
    # @note A nil default is permitted for testing purposes, but in practice,
    #   it will raise an exception when next_cue is undefined.
    #
    # @raise [ArgumentError] if the actor fails to start a scene.
    #
    # @param default [Scene, Symbol, nil]
    # @return [Take]
    def start_cue
      unless next_cue
        logger.debug "Using default scene for actor without cue"
        cue :default_scene
      end

      available = scenebooks.map { |sb| sb[next_cue.scene] }.compact
      raise "Scene named #{next_cue.scene} does not exist" if available.empty?

      logger.warn "Found #{available.count} scenes named `#{next_cue.scene}`" if available.length > 1

      take = Take.new(self, available.last, **next_cue.context)
      @concluding = take.conclusion?
      @last_cue = @next_cue
      @next_cue = nil
      take
    end

    # Restart the scene from the most recent cue.
    #
    # @return [Cue, nil]
    def recue
      if @last_cue
        cue @last_cue.scene, **@last_cue.context
      else
        logger.warn "No scene to recue"
        @next_cue = nil
      end
    end

    # Cue a conclusion. This method works like #cue, except it will raise an
    # error if the scene is not a Conclusion.
    #
    # @raise [ArgumentError] if the requested scene is not valid
    # @raise [NotConclusionError] if the scene is not a Conclusion
    #
    # @param new_scene [Scene]
    # @oaram context [Hash] Additional scene data
    def conclude new_scene, **context
      cue new_scene, **context
      # raise NotConclusionError unless next_cue.scene.rig <= Rig::Conclusion

      next_cue
    end

    # True if the actor starts a concluded cue.
    #
    def concluding?
      @concluding
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
      klass = (scene.is_a?(Gamefic::Base) ? scene.class : scene)
      entered_scenes.add klass
    end

    # Determine whether the entity has performed the specified scene.
    #
    # @return [Boolean]
    def entered? scene
      klass = (scene.is_a?(Gamefic::Base) ? scene.class : scene)
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

    # @return [Set<Gamefic::Base>]
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

    # @return [Array<Dispatcher>]
    def dispatchers
      @dispatchers ||= []
    end

    # @param scene [Scene, Symbol]
    # @return [Scene, nil]
    def select_scene scene
      scene.is_a?(Scene) ? select_scene_by_instance(scene) : select_scene_by_name(scene)
    end
  end
end
