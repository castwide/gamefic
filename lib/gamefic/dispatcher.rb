# frozen_string_literal: true

module Gamefic
  # The action executor for character commands.
  #
  class Dispatcher
    # @param actor [Actor]
    # @param command [Command]
    def initialize actor, command
      @actor = actor
      @command = command
      @executed = false
      @finalized = false
    end

    # Run the dispatcher.
    #
    # @return [Action, nil]
    def execute
      return if @executed

      @executed = true
      action = next_action
      return unless action

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
      expressions = Syntax.tokenize(input, actor.epic.syntaxes)
      command = compose(actor, expressions)
      new(actor, command)
    end

    # @param actor [Active]
    # @param verb [Symbol]
    # @param params [Array<Object>]
    # @return [Dispatcher]
    def self.dispatch_from_params actor, verb, params
      command = Command.new(verb, params)
      new(actor, command)
    end

    class << self
      private

      # @param actor [Actor]
      # @param expressions [Array<Expression>]
      # @return [Command]
      def compose actor, expressions
        expressions.flat_map { |expression| expression_to_commands(actor, expression) }
                   .first || Command.new(nil, [])
      end

      # @param actor [Actor]
      # @param expression [Expression]
      # @return [Array<Command>]
      def expression_to_commands actor, expression
        actor.epic
             .responses_for(expression.verb)
             .map { |response| response.to_command(actor, expression) }
             .compact
             .sort_by.with_index { |result, idx| [-result.precision, -result.strictness, idx] }
      end
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
      finalize
    end

    # If the dispatcher proceeds through all possible responses, it can fall
    # back to a nil response as a catchall for commands that could not be
    # completed.
    #
    # @return [Action, nil]
    def finalize
      return nil if @finalized

      @finalized = true
      @command = Command.new(nil, ["#{command.verb} #{command.arguments.join(' ').strip}"])
      @responses = actor.epic.responses_for(nil)
      next_action
    end
  end
end
