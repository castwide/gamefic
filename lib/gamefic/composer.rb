# frozen_string_literal: true

module Gamefic
  # A function module for creating commands from expressions.
  #
  module Composer
    # @param actor [Actor]
    # @param expressions [Array<Expression>]
    # @return [Command]
    def self.compose actor, expressions
      expressions.flat_map { |expression| to_commands(actor, expression) }
                 .first || Command.new(nil, [])
    end

    class << self
      private

      # @param actor [Actor]
      # @param expression [Expression]
      # @return [Array<Command>]
      def to_commands actor, expression
        actor.epic
             .responses_for(expression.verb)
             .map { |response| response.to_command(actor, expression) }
             .compact
             .sort_by.with_index { |result, idx| [-result.precision, -result.strictness, idx] }
      end
    end
  end
end
