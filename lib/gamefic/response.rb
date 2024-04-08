# frozen_string_literal: true

module Gamefic
  # A proc to be executed in response to a command that matches its verb and
  # queries.
  #
  class Response
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Query::Base>]
    attr_reader :queries

    # @return [Narrative]
    attr_reader :narrative

    # @param verb [Symbol]
    # @param narrative [Narrative]
    # @param queries [Array<Query::Base>]
    # @param meta [Boolean]
    # @param block [Proc]
    def initialize verb, narrative, *queries, meta: false, &block
      @verb = verb
      @narrative = narrative
      @queries = map_queryable_objects(queries)
      @meta = meta
      @block = block
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
      return false if command.verb != verb || command.arguments.length != queries.length

      queries.each_with_index do |query, idx|
        return false unless query.accept?(actor, command.arguments[idx])
      end

      true
    end

    def execute *args
      Stage.run(narrative, *args, &@block)
    end

    def precision
      @precision ||= calculate_precision
    end

    private

    def generate_default_syntax
      user_friendly = verb.to_s.gsub(/_/, ' ')
      args = []
      used_names = []
      queries.each do |_c|
        num = 1
        new_name = ":var"
        while used_names.include? new_name
          num += 1
          new_name = ":var#{num}"
        end
        used_names.push new_name
        user_friendly += " #{new_name}"
        args.push new_name
      end
      Syntax.new(user_friendly.strip, "#{verb} #{args.join(' ')}".strip)
    end

    def calculate_precision
      total = 0
      queries.each { |q| total += q.precision }
      total -= 1000 if verb.nil?
      total
    end

    def map_queryable_objects queries
      # @todo Considering moving mapping from Actions to here
      queries
    end
  end
end
