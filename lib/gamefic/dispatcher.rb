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
    end

    # Get the next executable action.
    #
    # @return [Action, nil]
    def proceed
      while (response = responses.shift)
        commands.each do |cmd|
          action = response.attempt(actor, cmd, !@started)
          next unless action && arguments_match?(action.arguments)

          @started = true
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
      commands = Syntax.tokenize(input, actor.rulebooks.flat_map(&:syntaxes))
      verbs = commands.map(&:verb).uniq
      responses = actor.rulebooks
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
      responses = actor.rulebooks
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
  end
end
