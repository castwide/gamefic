# frozen_string_literal: true

module Gamefic
  # The handler for executing a command response.
  #
  class Action
    include Scriptable::Queries

    attr_reader :actor, :command, :response, :model

    # @param actor [Actor]
    # @param command [Command]
    # @param response [Response]
    # @param model [Model]
    def initialize actor, command, response, model = nil
      Gamefic.logger.warn "Creating an action with a model" if model
      @actor = actor
      @command = command
      @response = model&.unproxy(response) || response
      @model = model
    end

    def execute
      return if cancelled?

      if valid?
        model&.execute(actor, *command.arguments, &response.block) || response.callback.run(actor, *command.arguments)
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

    def cancel
      @cancelled = true
    end

    def cancelled?
      @cancelled
    end

    private

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
      selectors = model&.unproxy(query.arguments) || query.arguments
      available = query.span(actor).that_are(*selectors)
      if query.ambiguous?
        argument & available == argument
      else
        available.include? argument
      end
    end
  end
end
