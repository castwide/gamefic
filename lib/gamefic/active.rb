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

    # The playbooks that will be used to perform commands. Every plot and
    # subplot has its own playbook.
    #
    # @return [Set<Gamefic::World::Playbook>]
    def playbooks
      @playbooks ||= Set.new
    end

    # The scenebooks that will be used to participate in scenes. Every plot and
    # subplot has its own scenebook.
    #
    # @return [Set<Gamefic::World::Scenebook>]
    def scenebooks
      @scenebooks ||= Set.new
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
      messenger.tell message
    end

    # Send a message to the entity as raw text.
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
      a = dispatchers&.last&.proceed
      if quietly
        messenger.buffer { a&.execute }
      else
        a&.execute
      end
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

      @next_cue = Cue.new(scene, context)
    end
    alias prepare cue

    # Start a take from the next cue. Start the default cue if a next one has
    # not been selected.
    #
    # @raise [ArgumentError] if the scene in next_cue does not exist.
    #
    # @param default [Scene, Symbol, nil]
    # @return [Take]
    def start_cue
      ensure_cue
      available = scenebooks.map { |sb| sb[next_cue.scene] }.compact
      validate_scene_selection(available)
      new_take(available.last, **next_cue.context)
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
    # @param new_scene [Scene]
    # @oaram context [Hash] Additional scene data
    def conclude scene, **context
      cue scene, **context
      available = scenebooks.map { |sb| sb[scene] }.compact.last
      raise ArgumentError, "`#{scene}` is not a conclusion" unless available.conclusion?

      @next_cue
    end

    # True if the actor is ready to leave the game.
    #
    def concluding?
      (playbooks.empty? && scenebooks.empty?) || scenebooks.map { |sb| sb[@last_cue&.scene] }.compact.last&.conclusion?
    end

    def accessible?
      false
    end

    private

    def messenger
      @messenger ||= Messenger.new
    end

    # @return [Array<Dispatcher>]
    def dispatchers
      @dispatchers ||= []
    end

    def ensure_cue
      return if next_cue

      logger.debug "Using default scene for actor without cue"
      cue :default_scene
    end

    def validate_scene_selection scenes
      raise ArgumentError, "Scene named `#{next_cue.scene}` does not exist" if scenes.empty?

      logger.warn "Found #{scenes.length} scenes named `#{next_cue.scene}`" if scenes.length > 1
    end

    def new_take scene, **context
      take = Take.new(self, scene, **context)
      @last_cue = @next_cue
      @next_cue = nil
      take
    end
  end
end
