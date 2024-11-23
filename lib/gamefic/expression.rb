# frozen_string_literal: true

module Gamefic
  # A tokenization of an input from available syntaxes.
  #
  class Expression
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<String>]
    attr_reader :tokens

    # @param verb [Symbol, nil]
    # @param tokens [Array<String>]
    def initialize(verb, tokens)
      @verb = verb
      @tokens = tokens
    end

    def inspect
      "#<#{self.class} #{([verb] + tokens).map(&:inspect).join(', ')}>"
    end
  end
end
