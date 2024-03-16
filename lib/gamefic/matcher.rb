module Gamefic
  module Matcher
    # @param actor [Actor]
    # @param command [Command]
    # @return [Array<Object>]
    def self.match actor, commands, responses
      commands.each do |command|
        result = strict_match_response_arguments(actor, command, responses) || fuzzy_match_response_arguments(actor, command, responses)
        return result if result
      end
      nil
    end

    class << self
      private

      def strict_match_response_arguments actor, command, responses
        match_response_arguments actor, command, responses, :strict
      end

      def fuzzy_match_response_arguments actor, command, responses
        match_response_arguments actor, command, responses, :fuzzy
      end

      def match_response_arguments actor, command, responses, method
        responses.each do |response|
          next unless response.queries.length >= command.tokens.length

          remainder = ''
          arguments = []
          response.queries.each_with_index do |query, idx|
            if query.is_a?(Query::Text)
              break if method == :strict
              result = query.query(actor, command.tokens[idx])
              break unless result.match

              arguments.push command.tokens[idx]
              remainder = result.remainder
            else
              result = Scanner.send(method, query.select(actor), "#{remainder} #{command.tokens[idx]}".strip)
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

          return arguments
        end

        nil
      end
    end
  end
end
