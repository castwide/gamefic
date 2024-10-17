# frozen_string_literal: true

module Gamefic
  class Request
    def initialize(actor, input)
      @actor = actor
      @input = input
    end

    def to_actions
      Syntax.tokenize(input, actor.narratives.syntaxes)
            .flat_map { |expression| expression_to_actions(actor, expression) }
            .sort_by.with_index { |action, idx| [-action.substantiality, -action.strictness, -action.precision, idx] }
    end

    private

    # @return [Actor]
    attr_reader :actor

    # @return [String]
    attr_reader :input

    def expression_to_actions(actor, expression)
      Gamefic.logger.info "Evaluating #{expression.inspect}"
      actor.narratives
           .responses_for(expression.verb)
           .map { |response| match_expression response, expression }
           #  .select(&:valid?) # @todo or .compact
           .compact
           .map { |request| Action.new(actor, request[:response], request[:matches]) }
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

        # @todo Get the remainder out of the token, maybe
        results.push Match.new(result.match, token, result.strictness)
        remainder = result.remainder
      end
      return nil unless remainder.empty?

      { response: response, matches: matches }
    end
  end
end
