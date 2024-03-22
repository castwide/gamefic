# frozen_string_literal: true

module Gamefic
  # The action selector for character commands.
  #
  class Dispatcher
    # @param actor [Actor]
    # @param expressions [Array<Expression>]
    # @param responses [Array<Response>]
    def initialize actor, expressions = [], responses = []
      @actor = actor
      @expressions = expressions
      @responses = responses
      @executed = false
      if expressions.first.is_a?(Command)
        @match = expressions.first
      else
        @match = Matcher.match(actor, expressions, responses)
      end
    end

    # Run the dispatcher.
    #
    def execute
      return if @executed

      @executed = true
      action = proceed
      return unless action

      run_before_action_hooks action
      return if action.cancelled?

      action.execute
      run_after_action_hooks action
    end

    # Get the next executable action.
    #
    # @return [Action, nil]
    def proceed
      while (response = responses.shift)
        next if response.queries.length < @match.arguments.length

        return Action.new(actor, @match.arguments, response) if response.accept?(actor, @match)
      end
      nil
    end

    # @param actor [Active]
    # @param input [String]
    # @return [Dispatcher]
    def self.dispatch actor, input
      commands = Syntax.tokenize(input, actor.epic.rulebooks.flat_map(&:syntaxes))
      verbs = commands.map(&:verb).uniq
      responses = actor.epic
                       .rulebooks
                       .to_a
                       .reverse
                       .flat_map { |pb| pb.responses_for(*verbs) }
                       .reject(&:hidden?)
      new(actor, commands, responses)
    end

    # @param actor [Active]
    # @param verb [Symbol]
    # @param params [Array<Object>]
    # @return [Dispatcher]
    def self.dispatch_from_params actor, verb, params
      command = Command.new(verb, params)
      responses = actor.epic
                       .rulebooks
                       .to_a
                       .reverse
                       .flat_map { |pb| pb.responses_for(verb) }
      new(actor, [command], responses)
    end

    protected

    # @return [Actor]
    attr_reader :actor

    # @return [Array<Command>]
    attr_reader :commands

    # @return [Array<Response>]
    attr_reader :responses

    private

    def arguments_match? action
      action.arguments == @match || action.arguments.all? { |arg| arg.is_a?(String) }
    end

    def run_before_action_hooks action
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.run_before_actions action }
    end

    def run_after_action_hooks action
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.run_after_actions action }
    end
  end
end
