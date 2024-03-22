module Gamefic
  module Matcher
    # @param actor [Actor]
    # @param expressions [Array<expression>]
    # @return [Command, nil]
    def self.match actor, expressions, responses
      %i[strict fuzzy].each do |method|
        expressions.each do |expression|
          result = match_response_arguments(actor, expression, responses, method)
          return result if result
        end
      end
      nil
    end

    class << self
      private

      def match_response_arguments actor, expression, responses, method
        responses.each do |response|
          next unless response.queries.length >= expression.tokens.length

          remainder = response.verb ? '' : expression.verb.to_s
          arguments = []
          response.queries.each_with_index do |query, idx|
            if query.is_a?(Query::Text)
              break if method == :strict

              result = query.query(actor, "#{remainder} #{expression.tokens[idx]}".strip)
              break unless result.match

              arguments.push result.match
              remainder = result.remainder
            else
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
          end

          next if arguments.length != response.queries.length

          return Command.new(response.verb, arguments)
        end

        nil
      end
    end
  end
end
