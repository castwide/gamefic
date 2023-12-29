# frozen_string_literal: true

require 'set'
require 'gamefic/active/cue'
require 'json'

module Gamefic
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

    # @return [Symbol, nil]
    def next_scene
      next_cue&.scene
    end

    # The rulebooks that will be used to perform commands. Every plot and
    # subplot has its own rulebook.
    #
    # @return [Set<Gamefic::World::Rulebook>]
    # def rulebooks
    #   @rulebooks ||= Set.new
    # end

    # The narratives in which the entity is participating.
    #
    # @return [Epic]
    def epic
      @epic ||= Epic.new
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
    #
    # This method will automatically wrap the message in HTML paragraphs.
    # To send a message without paragraph formatting, use #stream instead.
    #
    # @param message [String]
    def tell(message)
      messenger.tell message
    end

    # Send a message to the entity as raw text.
    #
    # Unlike #tell, this method will not wrap the message in HTML paragraphs.
    #
    # @param message [String]
    def stream(message)
      messenger.stream message
    end

    def messages
      messenger.messages
    end

    def buffer &block
      messenger.buffer(&block)
    end

    def flush
      messenger.flush
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
      dispatchers.last.execute
      dispatchers.pop
    end

    # Quietly perform a command.
    # This method executes the command exactly as #perform does, except it
    # buffers the resulting output instead of sending it to messages.
    #
    # @param command [String]
    # @return [String] The output that resulted from performing the command.
    def quietly(command)
      dispatchers.push Dispatcher.dispatch(self, command)
      result = messenger.buffer { dispatchers.last.execute }
      dispatchers.pop
      result
    end

    # Perform an action.
    # This is functionally identical to the `perform` method, except the
    # action must be declared as a verb with a list of arguments. Use
    # `perform` if you need to parse a string as a command.
    #
    # The command will be executed immediately, regardless of the entity's
    # state.
    #
    # @example
    #   character.execute :take, @key
    #
    # @param verb [Symbol]
    # @param params [Array]
    # @return [Gamefic::Action]
    def execute(verb, *params)
      dispatchers.push Dispatcher.dispatch_from_params(self, verb, params)
      proceed
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
    # @return [void]
    def proceed
      dispatchers&.last&.proceed&.execute
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

      logger.debug "Overwriting existing cue `#{@next_cue.scene}` with `#{scene}`" if @next_cue

      @next_cue = Cue.new(scene, context)
    end
    alias prepare cue

    def start_take
      ensure_cue
      @last_cue = @next_cue
      cue :default_scene
      scene = epic.select_scene(@last_cue.scene)
      @props = Take.start(self, scene, @last_cue.context)
    end

    def finish_take
      return unless @last_cue

      scene = epic.select_scene(@last_cue.scene)
      Take.finish(self, scene, @last_cue.context, @props)
    end

    # Restart the scene from the most recent cue.
    #
    # @return [Cue, nil]
    def recue
      logger.warn "No scene to recue" unless @last_cue

      @next_cue = @last_cue
    end

    # Cue a conclusion. This method works like #cue, except it will raise an
    # error if the scene is not a conclusion.
    #
    # @raise [ArgumentError] if the requested scene is not a conclusion
    #
    # @param new_scene [Symbol]
    # @oaram context [Hash] Additional scene data
    def conclude scene, **context
      cue scene, **context
      available = epic.select_scene(scene)
      raise ArgumentError, "`#{scene}` is not a conclusion" unless available.conclusion?

      @next_cue
    end

    # True if the actor is ready to leave the game.
    #
    def concluding?
      epic.empty? || (@last_cue && epic.conclusion?(@last_cue.scene))
    end

    def accessible?
      false
    end

    def messenger
      @messenger ||= Messenger.new
    end

    private

    # @return [Array<Dispatcher>]
    def dispatchers
      @dispatchers ||= []
    end

    def ensure_cue
      return if next_cue

      logger.debug "Using default scene for actor without cue"
      cue :default_scene
    end
  end
end
