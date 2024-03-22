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
    def initialize verb, tokens
      @verb = verb
      @tokens = tokens
    end

    # Compare two syntaxes for the purpose of ordering them by relevance while
    # dispatching.
    #
    def compare other
      if verb == other.verb
        other.tokens.compact.length <=> tokens.compact.length
      else
        (other.verb ? 1 : 0) <=> (verb ? 1 : 0)
      end
    end
  end
end
