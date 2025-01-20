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

    # The total substantiality of the action, based on how many of the
    # arguments are concrete entities and whether the action has a verb.
    #
    def substantiality
      arguments.that_are(Entity).length + (verb ? 1 : 0)
    end

    # The total strictness of all the matches.
    #
    # The higher the strictness, the more precisely the tokens from the user
    # input match the arguments. For example, if the user is interacting with a
    # pencil, the command TAKE PENCIL is stricter than TAKE PEN.
    #
    # @return [Integer]
    def strictness
      matches.sum(0, &:strictness)
    end

    # The precision of the response.
    #
    # @return [Integer]
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

    # Sort an array of actions in the order in which a Dispatcher should
    # attempt to execute them.
    #
    # Order is determined by the actions' substantiality, strictness, and
    # precision. In the event of a tie, the most recently defined action has
    # higher priority.
    #
    # @param actions [Array<Action>]
    # @return [Array<Action>]
    def self.sort(actions)
      actions.sort_by.with_index do |action, idx|
        [-action.substantiality, -action.strictness, -action.precision, idx]
      end
    end
  end
end
