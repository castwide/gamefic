# frozen_literal_string: true

module Gamefic
  # A proc to be executed in response to a command that matches its verb and
  # queries.
  #
  class Response
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Query::Base>]
    attr_reader :querydefs
    alias queries querydefs

    # @return [Proc]
    attr_reader :block

    # @param verb [Symbol]
    # @param querydefs [Array<Query::Base>]
    # @param meta [Boolean]
    # @param block [Proc]
    def initialize verb, *querydefs, meta: false, &block
      @verb = verb
      @querydefs = querydefs
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
    # @param actor [Gamefic::Entity]
    # @param command [Command]
    # @param with_hooks [Boolean]
    # @return [Action, nil]
    def attempt actor, command, with_hooks = false
      return nil if command.verb != verb

      tokens = command.arguments
      result = []
      remainder = ''

      querydefs.each_with_index do |qd, i|
        txt = "#{remainder} #{tokens[i]}".strip
        return nil if txt.empty?

        response = qd.query(actor, txt)
        return nil if response.match.nil?

        result.push response.match

        remainder = response.remainder
      end

      return nil unless remainder.empty?

      Action.new(actor, result, self, with_hooks)
    end

    def precision
      @precision ||= calculate_precision
    end

    private

    def generate_default_syntax
      user_friendly = verb.to_s.gsub(/_/, ' ')
      args = []
      used_names = []
      querydefs.each do |_c|
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
  end
end
