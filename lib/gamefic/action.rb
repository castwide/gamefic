# frozen_string_literal: true

module Gamefic
  # The handler for executing a command response.
  #
  class Action
    include Scriptable::Queries

    # @return [Actor]
    attr_reader :actor

    # @return [Response]
    attr_reader :response

    # @return [Array<Match>]
    attr_reader :matches

    # @return [String, nil]
    attr_reader :input

    # @param actor [Actor]
    # @param response [Response]
    # @param matches [Array<Match>]
    # @param input [String, nil]
    def initialize(actor, response, matches, input = nil)
      @actor = actor
      @response = response
      @matches = matches
      @input = input
    end

    def verb
      response.verb
    end

    def command
      @command ||= Command.new(response.verb, matches.map(&:argument), response.meta?, input)
    end

    def queries
      response.queries
    end

    def arguments
      matches.map(&:argument)
    end

    def execute
      response.execute(actor, *arguments)
      self
    end

    def substantiality
      matches.map(&:argument).that_are(Entity).length + (verb ? 1 : 0)
    end

    def strictness
      matches.sum(0, &:strictness)
    end

    def precision
      response.precision
    end

    def valid?
      response.accept?(actor, command)
    end

    def invalid?
      !valid?
    end

    def meta?
      response.meta?
    end

    # @param actions [Array<Action>]
    # @return [Array<Action>]
    def self.sort(actions)
      actions.sort_by.with_index do |action, idx|
        [-action.substantiality, -action.strictness, -action.precision, idx]
      end
    end
  end
end
