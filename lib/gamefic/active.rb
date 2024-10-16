# frozen_string_literal: true

require 'set'
require 'gamefic/active/cue'
require 'gamefic/active/messaging'
require 'gamefic/active/narratives'

module Gamefic
  # The Active module gives entities the ability to perform actions and
  # participate in scenes. The Actor class, for example, is an Entity
  # subclass that includes this module.
  #
  module Active
    include Logging
    include Messaging

    # The most recently started cue.
    #
    # @return [Cue, nil]
    attr_reader :last_cue

    # The cue that will be started on the next turn.
    #
    # @return [Cue, nil]
    attr_reader :next_cue

    # @return [String, nil]
    attr_reader :last_input

    def current
      Binding.for(self) || narratives.first
    end

    # The narratives in which the entity is participating.
    #
    # @return [Set<Narrative>]
    def narratives
      @narratives ||= Narratives.new
    end

    # An array of commands waiting to be executed.
    #
    # @return [Array<String>]
    def queue
      @queue ||= []
    end

    # Data that will be sent to the user. The output is typically sent after a
    # scene has started and before the user is prompted for input.
    #
    # The output object attached to the actor is always frozen. Authors should
    # use on_player_output blocks to modify output to be sent to the user.
    #
    # @return [Props::Output]
    def output
      last_cue&.output || Props::Output.new.freeze
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
    # @return [Action, nil]
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
      messenger.buffer { perform command }
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
    # @return [Action, nil]
    def execute(verb, *params)
      dispatchers.push Dispatcher.dispatch_from_params(self, verb, params)
      dispatchers.last.execute
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
    # @return [Action, nil]
    def proceed
      dispatchers.last&.proceed
    end

    # Run a clip.
    #
    # @param clip_class [Class<Clip>]
    def run clip_class, **opts
      clip_class.run self, **opts
    end

    # Cue a scene to start in the next turn.
    #
    # @raise [ArgumentError] if the scene is not valid
    #
    # @param scene [Class<Scene::Base>, Symbol]
    # @param context [Hash] Extra data to pass to the scene's props
    # @return [Cue]
    def cue scene, **context
      return @next_cue if @next_cue&.key == scene && @next_cue&.context == context

      logger.debug "Overwriting existing cue `#{@next_cue.key}` with `#{scene}`" if @next_cue

      @next_cue = Cue.new(self, scene, current, **context)
    end
    alias prepare cue

    # Restart the scene from the most recent cue.
    #
    # @return [Cue, nil]
    def recue
      (@next_cue = @last_cue&.restart) || logger.warn("No scene to recue")
    end

    # True if the actor is ready to leave the game.
    #
    def concluding?
      narratives.empty? || @last_cue&.scene&.type == 'Conclusion'
    end

    def accessible?
      false
    end

    def acting?
      !narratives.empty?
    end

    # True if the actor can perform the verb in the current narrastives.
    #
    # @param verb [String, Symbol]
    def can?(verb)
      narratives.flat_map(&:synonyms).include?(verb.to_sym)
    end

    def last_interaction
      {
        last_prompt: @last_cue&.scene&.props&.prompt,
        last_input: @last_cue&.scene&.props&.input
      }
    end

    # Move next_cue into last_cue. This method is typically called by the plot
    # at the start of a turn.
    #
    def cue_started
      @last_cue = @next_cue
      @next_cue = nil
    end

    private

    # @return [Array<Dispatcher>]
    def dispatchers
      @dispatchers ||= []
    end
  end
end
