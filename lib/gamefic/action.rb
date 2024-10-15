# frozen_string_literal: true

module Gamefic
  # The handler for executing a command response.
  #
  class Action
    include Scriptable::Queries

    attr_reader :actor, :command, :response

    # @param actor [Actor]
    # @param command [Command]
    # @param response [Response]
    def initialize actor, command, response
      @actor = actor
      @command = command
      @response = response
    end

    def execute
      return if cancelled?

      if valid?
        Gamefic.logger.info "Executing #{@response.inspect}"
        @response.execute(actor, *command.arguments)
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
               .all? { |query, argument| query.accept?(actor, argument) }
    end
  end
end
