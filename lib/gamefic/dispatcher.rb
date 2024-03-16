# frozen_string_literal: true

module Gamefic
  # The action selector for character commands.
  #
  class Dispatcher
    # @param actor [Actor]
    # @param commands [Array<Command>]
    # @param responses [Array<Response>]
    def initialize actor, commands = [], responses = []
      @actor = actor
      @commands = commands
      @responses = responses
      @executed = false
      @match = Matcher.match(actor, commands, responses)
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
        commands.each do |cmd|
          action = response.attempt(actor, cmd)
          next unless action && arguments_match?(action)

          return action
        end
      end
      nil # Without this, return value in Opal is undefined
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
