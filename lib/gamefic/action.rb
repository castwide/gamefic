# frozen_string_literal: true

module Gamefic
  # The handler for executing a command response.
  #
  class Action
    include Scriptable::Queries

    attr_reader :actor, :request

    # @param actor [Actor]
    # @param request [Response::Request]
    def initialize actor, request
      @actor = actor
      @request = request
    end

    def response
      request.response
    end

    def command
      @command ||= Command.new(request.verb, request.arguments)
    end

    def execute
      return if cancelled?

      if valid?
        Gamefic.logger.info "Executing #{request.response.inspect}"
        request.response.execute(actor, *command.arguments)
        self
      else
        actor.proceed
      end
    end

    def substantiality
      @substantiality ||= request.arguments.that_are(Entity).length + (request.verb ? 1 : 0)
    end

    def strictness
      request.strictness
    end

    def precision
      request.response.precision
    end

    def valid?
      request.valid?
    end

    def invalid?
      !valid?
    end

    def meta?
      request.response.meta?
    end

    def cancel
      @cancelled = true
    end

    def cancelled?
      @cancelled
    end

    class << self
      def compose actor, input
        Syntax.tokenize(input, actor.narratives.syntaxes)
              .flat_map { |expression| expression_to_actions(actor, input, expression) }
              .sort_by.with_index { |action, idx| [-action.substantiality, -action.strictness, -action.precision, idx] }
      end

      private

      def expression_to_actions(actor, input, expression)
        Gamefic.logger.info "Evaluating #{expression.inspect}"
        actor.narratives
             .responses_for(expression.verb)
             .map { |response| response.request(actor, expression) }
             .select(&:valid?)
             .map { |request| Action.new(actor, request) }
      end
    end
  end
end
