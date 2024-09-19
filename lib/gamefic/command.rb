# frozen_string_literal: true

module Gamefic
  # A concrete representation of an input as a verb and an array of arguments.
  #
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Array<Entity>, Entity, String>]
    attr_reader :arguments

    # @return [Integer]
    attr_reader :strictness

    # @return [Integer]
    attr_reader :precision

    # @param verb [Symbol]
    # @param arguments [Array<Array<Entity>, Entity, String>]
    # @param strictness [Integer]
    # @param precision [Integer]
    #
    # @todo Consider making strictness and precision required or providing
    #   another generator
    def initialize verb, arguments, strictness = 0, precision = 0
      @verb = verb
      @arguments = arguments
      @strictness = strictness
      @precision = precision
    end

    class << self
      # @param actor [Actor]
      # @param expressions [Array<Expression>]
      # @return [Command]
      def compose actor, expressions
        expressions.flat_map { |expression| expression_to_commands(actor, expression) }
                   .first || Command.new(nil, [])
      end

      private

      # @param actor [Actor]
      # @param expression [Expression]
      # @return [Array<Command>]
      def expression_to_commands actor, expression
        actor.epic
             .responses_for(expression.verb)
             .map { |response| response.to_command(actor, expression) }
             .compact
             .sort_by.with_index { |result, idx| [-result.precision, -result.strictness, idx] }
      end
    end
  end
end
