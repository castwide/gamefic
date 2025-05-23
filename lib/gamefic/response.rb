# frozen_string_literal: true

require 'gamefic/scriptable'

module Gamefic
  # A proc to be executed in response to a command that matches its verb and
  # queries.
  #
  class Response
    include Scriptable::Queries

    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Query::Base, Query::Text>]
    attr_reader :queries

    # @return [Proc]
    attr_reader :block

    # @param verb [Symbol]
    # @param queries [Array<Object>]
    # @param meta [Boolean]
    def initialize verb, *queries, meta: false, &block
      @verb = verb&.to_sym
      @meta = meta
      @block = block
      @queries = map_queries(queries)
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
      Gamefic.logger.warn "Executing unbound response #{inspect}" unless bound?
      gamefic_binding.call(*args)
    end

    # The total precision of all the response's queries.
    #
    # @note Precision is decreased if the response has a nil verb.
    #
    # @return [Integer]
    def precision
      @precision ||= calculate_precision
    end

    def inspect
      "#<#{self.class} #{([verb] + queries).map(&:inspect).join(', ')}>"
    end

    def bound?
      !!gamefic_binding.narrative
    end

    def bind(narrative)
      clone.inject_binding narrative
    end

    protected

    def inject_binding(narrative)
      @queries = map_queries(narrative.unproxy(@queries))
      @gamefic_binding = Binding.new(narrative, @block)
      self
    end

    private

    def gamefic_binding
      @gamefic_binding ||= Binding.new(nil, @block)
    end

    def generate_default_syntax
      args = queries.length.times.map { |num| num.zero? ? ':var' : ":var#{num + 1}" }
      tmpl = "#{verb} #{args.join(' ')}".strip
      Syntax.new(tmpl, tmpl)
    end

    # @return [Integer]
    def calculate_precision
      total = queries.sum(&:precision)
      total -= 1000 unless verb
      total
    end

    def map_queries(args)
      args.map { |arg| select_query(arg) }
    end

    def select_query(arg)
      case arg
      when Entity, Class, Module, Proc, Proxy::Base
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
