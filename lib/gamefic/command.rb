# frozen_string_literal: true

module Gamefic
  # A concrete representation of an input as a verb and an array of arguments.
  #
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Array<Entity>, Entity, String>]
    attr_reader :arguments

    # @return [Array<String>, nil]
    attr_reader :tokens

    # @return [Integer]
    attr_reader :strictness

    # @return [Integer]
    attr_reader :precision

    # @param verb [Symbol]
    # @param arguments [Array<Array<Entity>, Entity, String>]
    # @param expression [Expression, nil]
    # @param strictness [Integer]
    # @param precision [Integer]
    #
    # @todo Consider making strictness and precision required or providing
    #   another generator
    def initialize verb, arguments, tokens = arguments.map(&:to_s), strictness = 0, precision = 0
      @verb = verb
      @arguments = arguments
      @tokens = tokens
      @strictness = strictness
      @precision = precision
    end

    def substantiality
      @substantiality ||= arguments.that_are(Entity).length + (verb ? 1 : 0)
    end

    def inspect
      "#<#{self.class} #{([verb] + arguments).map(&:inspect).join(', ')}>"
    end

    class << self
      # Compose a command from input.
      #
      # @param actor [Actor]
      # @param input [String]
      # @return [Command]
      def compose actor, input
        expressions = Syntax.tokenize(input, actor.syntaxes)
        expressions.flat_map { |expression| expression_to_commands(actor, expression) }
                   .first || Command.new(nil, [])
      end

      private

      # @param actor [Actor]
      # @param expression [Expression]
      # @return [Array<Command>]
      def expression_to_commands actor, expression
        Gamefic.logger.info "Evaluating #{expression.inspect}"
        actor.narratives
             .flat_map { |narr| narr.responses_for(expression.verb) }
             .select { |response| response.queries.length == expression.tokens.length }
             .map { |response| response.to_command(actor, expression) }
             .compact
             .sort_by.with_index { |result, idx| [-result.substantiality, -result.strictness, -result.precision, idx] }
      end
    end
  end
end
