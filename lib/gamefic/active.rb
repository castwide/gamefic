# frozen_string_literal: true

require 'set'
require 'gamefic/active/cue'
require 'gamefic/active/epic'
require 'gamefic/active/messaging'

module Gamefic
  # The Active module gives entities the ability to perform actions and
  # participate in scenes. The Actor class, for example, is an Entity
  # subclass that includes this module.
  #
  module Active
    include Logging
    include Messaging

    # The cue that will be used to create a scene at the beginning of the next
    # turn.
    #
    # @return [Active::Cue, nil]
    attr_reader :next_cue

    # @return [String, nil]
    attr_reader :last_input

    # @return [Symbol, nil]
    def next_scene
      next_cue&.scene
    end

    def current
      Binding.for(self)
    end

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

    # Data that will be sent to the user. The output is typically sent after a
    # scene has started and before the user is prompted for input.
    #
    # The output object attached to the actor is always frozen. Authors should
    # use on_player_output blocks to modify output to be sent to the user.
    #
    # @return [Props::Output]
    def output
      @output ||= Props::Output.new.freeze
    end

    # The output from the previous turn.
    #
    # @return [Props::Output]
    def last_output
      @last_output ||= output
    end

    # The last executed command.
    #
    # @return [Command, nil]
    attr_reader :last_command

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
      dispatch_and_pop
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
      dispatch_and_pop
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
    # @param scene [Class<Scene::Default>, Symbol]
    # @param context [Hash] Extra data to pass to the scene's props
    # @return [Cue]
    def cue scene, **context
      return @next_cue if @next_cue&.scene == scene && @next_cue&.context == context

      logger.debug "Overwriting existing cue `#{@next_cue.scene}` with `#{scene}`" if @next_cue

      @next_cue = Cue.new(scene, **context)
    end
    alias prepare cue

    def start
      ensure_cue
      @last_cue = @next_cue
      cue epic.narratives.first&.default_scene
      @scene = epic.select_scene(@last_cue.scene).new(self, **@last_cue.context)
      @scene.start
      @output = @scene.props.output.dup.freeze
    end

    def finish
      return unless @scene

      @scene.finish
      @scene.run_finish_blocks
      @last_input = @scene.props.input
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
    # @return [Cue]
    def conclude scene, **context
      cue scene, **context
      available = epic.select_scene(scene)
      raise ArgumentError, "`#{scene}` is not a conclusion" unless available.conclusion?

      @next_cue
    end

    # True if the actor is ready to leave the game.
    #
    def concluding?
      epic.empty? || @scene&.type == 'Conclusion'
    end

    def accessible?
      false
    end

    def acting?
      !epic.empty?
    end

    def cancel
      dispatchers.last&.cancel
    end
    alias stop cancel

    def executing?
      !dispatchers.empty?
    end

    def cancelled?
      dispatchers.last&.cancelled?
    end
    alias stopped? cancelled?

    # @return [Command]
    def command
      dispatchers.last&.command || Command.new(nil, [])
    end

    def match context
      return nil unless context

      matches = epic.narratives
                    .select { |narr| narr.is_a?(context) }
      Gamefic.logger.warn "#{inspect} is in #{matches.length} instances of #{context.inspect}" if matches.length > 1

      matches.last
    end

    private

    # @return [Array<Dispatcher>]
    def dispatchers
      @dispatchers ||= []
    end

    def dispatch_and_pop
      dispatchers.last.execute.tap do
        @last_command = dispatchers.last.command
        dispatchers.pop
      end
    end

    def ensure_cue
      return if next_cue

      logger.debug "Using default scene for actor without cue"
      cue epic.narratives.first&.default_scene
    end
  end
end
