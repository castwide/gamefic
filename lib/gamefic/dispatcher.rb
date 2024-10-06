# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    include Logging

    # @param actor [Actor]
    # @param command [Command]
    def initialize actor, command
      @actor = actor
      @command = command
      @executed = false
    end

    # Run the dispatcher.
    #
    # @return [Action, nil]
    def execute
      return if @executed

      @executed = true
      action = next_action
      return unless action

      logger.info "Executing #{action.response.inspect} from command #{command.inspect}"
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.run_before_actions action }
      return if action.cancelled?

      action.execute
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.run_after_actions action }
      action
    end

    # Execute the next available action.
    #
    # Actors should run #execute first.
    #
    # @return [Action, nil]
    def proceed
      return unless @executed

      next_action&.execute
    end

    # @param actor [Active]
    # @param input [String]
    # @return [Dispatcher]
    def self.dispatch actor, input
      # expressions = Syntax.tokenize(input, actor.epic.syntaxes)
      # new(actor, Command.compose(actor, expressions))
      new(actor, Command.compose(actor, input))
    end

    # @param actor [Active]
    # @param verb [Symbol]
    # @param params [Array<Object>]
    # @return [Dispatcher]
    def self.dispatch_from_params actor, verb, params
      command = Command.new(verb, params)
      new(actor, command)
    end

    protected

    # @return [Actor]
    attr_reader :actor

    # @return [Command]
    attr_reader :command

    # @return [Array<Response>]
    def responses
      @responses ||= actor.epic.responses_for(command.verb)
    end

    private

    # @return [Action, nil]
    def next_action
      while (response = responses.shift)
        next if response.queries.length < @command.arguments.length

        return Action.new(actor, @command.arguments, response) if response.accept?(actor, @command)
      end
    end
  end
end
