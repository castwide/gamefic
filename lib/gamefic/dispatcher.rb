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
          next unless action && arguments_match?(action.arguments)

          @pattern ||= action.arguments
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

    # After the first action gets selected, subsequent actions need to use the
    # same arguments.
    #
    def arguments_match? arguments
      return true unless @pattern

      arguments == @pattern
    end

    def run_before_action_hooks action
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.hooks.run_before_actions action }
    end

    def run_after_action_hooks action
      actor.epic.rulebooks.flat_map { |rlbk| rlbk.hooks.run_after_actions action }
    end
  end
end
