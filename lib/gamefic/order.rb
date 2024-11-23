# frozen_string_literal: true

module Gamefic
  # Build actions from explicit verbs and arguments.
  #
  # The Active#execute method uses Order to bypass the parser while
  # generating actions to be executed in the Dispatcher.
  #
  class Order
    # @param actor [Actor]
    # @param verb [Symbol]
    # @param arguments [Array<Object>]
    def initialize(actor, verb, arguments)
      @actor = actor
      @verb = verb
      @arguments = arguments
    end

    # @return [Array<Action>]
    def to_actions
      actor.narratives
           .responses_for(verb)
           .map { |response| match_arguments(response) }
           .compact
           .map { |result| Action.new(actor, result[0], result[1], nil) }
    end

    private

    # @return [Actor]
    attr_reader :actor

    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Object>]
    attr_reader :arguments

    def match_arguments(response)
      return nil if response.queries.length != arguments.length

      matches = response.queries.zip(arguments).each_with_object([]) do |zipped, result|
        query, param = zipped
        return nil unless query.accept?(actor, param)

        result.push Match.new(param, param, 1000)
      end
      [response, matches]
    end
  end
end
