module Gamefic
  # A function module for creating commands from expressions.
  #
  module Matcher
    # Create a command from the first expression that matches a response.
    #
    # @param actor [Actor]
    # @param expressions [Array<expression>]
    # @return [Command]
    def self.match actor, expressions
      verbs = expressions.map(&:verb).uniq
      responses = actor.epic.responses_for(*verbs)
      %i[strict fuzzy].each do |method|
        expressions.each do |expression|
          result = match_response_arguments(actor, expression, responses, method)
          return result if result
        end
      end
      Command.new(nil, [])
    end

    class << self
      private

      def match_response_arguments actor, expression, responses, method
        responses.each do |response|
          next unless response.queries.length >= expression.tokens.length

          remainder = response.verb ? '' : expression.verb.to_s
          arguments = []
          response.queries.each_with_index do |query, idx|
            result = Scanner.send(method, query.select(actor), "#{remainder} #{expression.tokens[idx]}".strip)
            break if result.matched.empty?

            break if result.matched.length > 1 && !query.ambiguous?

            if query.ambiguous?
              arguments.push result.matched
            else
              arguments.push result.matched.first
            end
            remainder = result.remainder
          end

          next if arguments.length != response.queries.length || remainder != ''

          return Command.new(response.verb, arguments)
        end

        nil
      end
    end
  end
end
