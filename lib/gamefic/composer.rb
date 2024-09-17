# frozen_string_literal: true

module Gamefic
  # A function module for creating commands from expressions.
  #
  module Composer
    class Result
      attr_reader :command, :level, :precision

      def initialize command, level, precision
        @command = command
        @level = level
        @precision = precision
      end
    end

    # Create a command from the first expression that matches a response.
    #
    # @param actor [Actor]
    # @param expressions [Array<Expression>]
    # @return [Command]
    def self.compose actor, expressions
      results = Scanner.processors.flat_map do |processor|
        match_expressions_to_response actor, expressions, processor
      end
      .compact
      .sort_by.with_index { |result, idx| [-result.precision, result.level, idx] }

      results.first&.command || Command.new(nil, [])
    end

    class << self
      private

      def match_expressions_to_response actor, expressions, processor
        expressions.each do |expression|
          result = match_response_arguments actor, expression, processor
          return result if result
        end
        nil
      end

      def match_response_arguments actor, expression, processor
        actor.epic.responses_for(expression.verb).each do |response|
          next unless response.queries.length >= expression.tokens.length

          result = match_query_arguments(actor, expression, response, processor)
          return result if result
        end
        nil
      end

      def match_query_arguments actor, expression, response, processor
        remainder = response.verb ? '' : expression.verb.to_s
        arguments = []
        response.queries.each_with_index do |query, idx|
          result = query.scan(actor, "#{remainder} #{expression.tokens[idx]}".strip, [processor])
          break unless valid_result_from_query?(result, query)

          if query.ambiguous?
            arguments.push result.matched
          else
            arguments.push result.matched.first
          end
          remainder = result.remainder
        end

        return nil if arguments.length != response.queries.length || remainder != ''

        Result.new(Command.new(response.verb, arguments), Scanner.processors.find_index(processor), response.precision)
      end

      # @param result [Scanner::Result]
      # @param query [Query::Base]
      def valid_result_from_query? result, query
        return false if result.matched.empty?

        result.matched.length == 1 || query.ambiguous?
      end
    end
  end
end
