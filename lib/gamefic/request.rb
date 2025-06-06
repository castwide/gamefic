# frozen_string_literal: true

module Gamefic
  # Build actions from text.
  #
  # Active#perform uses Request to parse user input into actions for execution
  # by the Dispatcher.
  #
  class Request
    # @param actor [Actor]
    # @param input [String]
    def initialize(actor, input)
      @actor = actor
      @input = input
    end

    # @return [Array<Action>]
    def to_actions
      Action.sort(
        Syntax.tokenize(input, actor.narratives.syntaxes)
              .flat_map { |expression| expression_to_actions(expression) }
      )
    end

    private

    # @return [Actor]
    attr_reader :actor

    # @return [String]
    attr_reader :input

    def expression_to_actions(expression)
      Gamefic.logger.info "Evaluating #{expression.inspect}"
      actor.narratives
           .responses_for(expression.verb)
           .map { |response| match_expression response, expression }
           .compact
    end

    def match_expression(response, expression)
      return nil if expression.tokens.length > response.queries.length

      remainder = ''
      matches = response.queries
                        .zip(expression.tokens)
                        .each_with_object([]) do |zipped, results|
        query, token = zipped
        result = query.filter(actor, "#{remainder} #{token}".strip)
        return nil unless result.match

        results.push Match.new(result.match, token.to_s[0..-result.remainder.length - 1], result.strictness)
        remainder = result.remainder
      end
      return nil unless remainder.empty?

      Action.new(actor, response, matches, input)
    end
  end
end
