# frozen_string_literal: true

module Gamefic
  # A proc to be executed in response to a command that matches its verb and
  # queries.
  #
  class Response
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Query::Base, Query::Text>]
    attr_reader :queries

    # @param verb [Symbol]
    # @param narrative [Narrative]
    # @param args [Array<Object>]
    # @param meta [Boolean]
    # @param block [Proc]
    def initialize verb, narrative, *args, meta: false, &block
      @verb = verb
      @queries = map_queries(args, narrative)
      @meta = meta
      @callback = Callback.new(narrative, block)
    end

    # The `meta?` flag is just a way for authors to identify responses that
    # serve a purpose other than performing in-game actions. Out-of-game
    # responses can include features like displaying help documentation or
    # listing credits.
    #
    def meta?
      @meta
    end

    def hidden?
      @hidden ||= verb.to_s.start_with?('_')
    end

    def syntax
      @syntax ||= generate_default_syntax
    end

    # Return an Action if the Response can accept the actor's command.
    #
    # @param actor [Entity]
    # @param command [Command]
    # @return [Action, nil]
    def attempt actor, command
      return nil unless accept?(actor, command)

      Action.new(actor, command.arguments, self)
    end

    # True if the Response can be executed for the given actor and command.
    #
    # @param actor [Active]
    # @param command [Command]
    def accept? actor, command
      command.verb == verb &&
        command.arguments.length == queries.length &&
        queries.zip(command.arguments).all? { |query, argument| query.accept?(actor, argument) }
    end

    def execute *args
      @callback.run(*args)
    end

    def precision
      @precision ||= calculate_precision
    end

    # Turn an actor and an expression into a command by matching the
    # expression's tokens to queries. Return nil if the expression
    # could not be matched.
    #
    # @param actor [Actor]
    # @param expression [Expression]
    # @return [Command, nil]
    def to_command actor, expression
      return nil unless expression.verb == verb && expression.tokens.length <= queries.length

      results = filter(actor, expression)
      return nil unless results

      Command.new(
        verb,
        results.map(&:match),
        expression.tokens,
        results.sum(&:strictness),
        precision
      )
    end

    private

    def filter actor, expression
      remainder = ''
      result = queries.zip(expression.tokens)
                      .map do |query, token|
                        token = "#{remainder} #{token}".strip
                        result = query.filter(actor, token)
                        return nil unless result.match

                        remainder = result.remainder
                        result
                      end
      result if remainder.empty?
    end

    def generate_default_syntax
      args = queries.length.times.map { |num| num.zero? ? ':var' : ":var#{num + 1}" }
      tmpl = "#{verb} #{args.join(' ')}".strip
      Syntax.new(tmpl.gsub('_', ' '), tmpl)
    end

    def calculate_precision
      total = queries.sum(&:precision)
      total -= 1000 unless verb
      total
    end

    def map_queries args, narrative
      args.map do |arg|
        select_query(arg, narrative).tap { |qry| qry.narrative = narrative }
      end
    end

    def select_query arg, narrative
      case arg
      when Entity, Class, Module, Proc, Proxy
        narrative.available(arg)
      when String, Regexp
        narrative.plaintext(arg)
      when Query::Base, Query::Text
        arg
      else
        raise ArgumentError, "invalid argument in response: #{arg.inspect}"
      end
    end
  end
end
