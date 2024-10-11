# frozen_string_literal: true

module Gamefic
  # The handler for executing a command response.
  #
  class Action
    include Scriptable::Queries

    # @param actor [Actor]
    # @param command [Command]
    # @param response [Response]
    # @param model [Model]
    def initialize actor, command, response, model
      @actor = actor
      @command = command
      @response = response
      @model = model
    end

    def execute
      if valid?
        model.execute actor, &response.block
        self
      else
        actor.proceed
      end
    end

    def valid?
      valid_verb? && valid_arity? && valid_arguments?
    end

    def invalid?
      !valid?
    end

    def meta?
      response.meta?
    end

    private

    attr_reader :actor, :command, :response, :model

    def valid_verb?
      command.verb == response.verb
    end

    def valid_arity?
      command.arguments.length == response.queries.length
    end

    def valid_arguments?
      @response.queries
               .zip(@command.arguments)
               .all? { |query, argument| accept? actor, query, argument, model }
    end

    def accept? actor, query, argument, model
      selectors = model.unproxy(query.arguments)
      available = query.span(actor).that_are(*selectors)
      if query.ambiguous?
        argument & available == argument
      else
        available.include? argument
      end
    end
  end
end
