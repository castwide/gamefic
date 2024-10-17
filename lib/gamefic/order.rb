module Gamefic
  class Order
    def initialize(actor, verb, arguments)
      @actor = actor
      @verb = verb
      @arguments = arguments
    end

    def to_actions
      actor.narratives
           .responses_for(verb)
           .map { |response| match_arguments actor, response, arguments }
          #  .select(&:valid?) # @todo or .compact
           .compact
           .map { |result| Action.new(actor, result[:response], result[:matches]) }
    end

    private

    # @return [Actor]
    attr_reader :actor

    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Object>]
    attr_reader :arguments

    def match_arguments(actor, response, params)
      return nil if response.queries.length != params.length

      matches = response.queries.zip(params).each_with_object([]) do |zipped, matches|
        query, param = zipped
        return nil unless query.accept?(actor, param)

        matches.push Match.new(param, param, 1000)
      end
      { response: response, matches: matches }
    end
  end
end
