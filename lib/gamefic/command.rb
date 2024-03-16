# frozen_string_literal: true

module Gamefic
  # A decomposition of a text-based command into its verb and arguments.
  #
  # Commands are typically derived from tokenization against syntaxes.
  #
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<String>]
    attr_reader :arguments
    alias tokens arguments

    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end

    # Compare two syntaxes for the purpose of ordering them by relevance while
    # dispatching.
    #
    def compare other
      if verb == other.verb
        other.arguments.compact.length <=> arguments.compact.length
      else
        (other.verb ? 1 : 0) <=> (verb ? 1 : 0)
      end
    end
  end
end
