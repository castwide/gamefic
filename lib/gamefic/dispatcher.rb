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
      @started = false
    end

    # Get the next executable action.
    #
    # @return [Action, nil]
    def next
      until responses.empty?
        response = responses.shift
        commands.each do |cmd|
          action = response.attempt(actor, cmd, !@started)
          if action
            @started = true
            return action
          end
        end
      end
      nil # Without this, return value in Opal is undefined
    end

    # @param actor [Active]
    # @param input [String]
    # @return [Dispatcher]
    def self.dispatch actor, input
      commands = Syntax.tokenize(input, actor.playbooks.flat_map(&:syntaxes))
      verbs = commands.map(&:verb).uniq
      responses = actor.playbooks
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
      responses = actor.playbooks
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
  end
end
