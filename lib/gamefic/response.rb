# frozen_string_literal: true

require 'gamefic/scriptable'

module Gamefic
  # A proc to be executed in response to a command that matches its verb and
  # queries.
  #
  class Response
    class Binding
      attr_reader :response
  
      attr_reader :model
  
      # @param response [Response]
      # @param model [Model]
      def initialize response, model
        @response = response
  
        @model = model
      end
    end
  
    include Scriptable::Queries

    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Query::Base, Query::Text>]
    attr_reader :queries

    attr_reader :block

    # @param verb [Symbol]
    # @param narrative [Narrative]
    # @param args [Array<Object>]
    # @param meta [Boolean]
    # @param block [Proc]
    def initialize verb, *args, meta: false, &block
      narrative = if args.first.is_a?(Narrative) || args.first.is_a?(Scriptable::Actions)
                    Gamefic.logger.warn "#{caller.first ? "#{caller.first}: " : ''}Script-level responses are deprecated. Use class-level responses instead."
                    args.shift
                  end
      Gamefic.logger.warn "Underscores to hide verbs (`#{verb}`) are deprecated." if verb.to_s.start_with?('_')
      @verb = verb
      @meta = meta
      @args = args
      @block = block
      # @queries = map_queries(args, narrative)
      @queries = map_queries_v4(args)
      # @todo Callback should not be necessary. Bind block in Action instead
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

    def syntax
      @syntax ||= generate_default_syntax
    end

    # Return an Action if the Response can accept the actor's command.
    #
    # @param actor [Entity]
    # @param command [Command]
    # @return [Action, nil]
    def attempt(actor, command)
      return nil unless accept?(actor, command)

      Action.new(actor, command.arguments, self)
    end

    # True if the Response can be executed for the given actor and command.
    #
    # @param actor [Active]
    # @param command [Command]
    def accept?(actor, command)
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
    def to_command(actor, expression)
      return log_and_discard unless expression.verb == verb && expression.tokens.length <= queries.length

      results = filter(actor, expression)
      return log_and_discard unless results

      Gamefic.logger.info "Accepted #{inspect}"
      Command.new(
        verb,
        results.map(&:match),
        expression.tokens,
        results.sum(&:strictness),
        precision
      )
    end

    def inspect
      "#<#{self.class} #{([verb] + queries).map(&:inspect).join(', ')}>"
    end

    def bind narrative
      clone.tap do |copy|
        copy.instance_exec do
          @narrative = narrative
          @queries = map_queries(@args, narrative)
          @callback = Callback.new(narrative, @block)
        end
      end
    end

    private

    def log_and_discard
      Gamefic.logger.info "Discarded #{inspect}"
      nil
    end

    def filter(actor, expression)
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
      Syntax.new(tmpl, tmpl)
    end

    def calculate_precision
      total = queries.sum(&:precision)
      total -= 1000 unless verb
      total
    end

    def map_queries(args, narrative)
      args.map do |arg|
        select_query(arg).tap { |qry| qry.narrative = narrative }
      end
    end

    def map_queries_v4(args)
      args.map { |arg| select_query(arg) }
    end

    def select_query(arg)
      case arg
      when Entity, Class, Module, Proc, Proxy, Proxy::Base
        available(arg)
      when String, Regexp
        plaintext(arg)
      when Query::Base
        arg
      else
        raise ArgumentError, "invalid argument in response: #{arg.inspect}"
      end
    end
  end
end
