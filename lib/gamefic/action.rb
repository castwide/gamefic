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

    # @param actor [Actor]
    # @param response [Response]
    # @param matches [Array<Match>]
    def initialize(actor, response, matches)
      @actor = actor
      @response = response
      @matches = matches
    end

    def verb
      response.verb
    end

    def command
      @command ||= Command.new(response.verb, matches.map(&:argument), response.meta?)
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
  end
end
