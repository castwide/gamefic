# frozen_string_literal: true

module Gamefic
  # A concrete representation of an input as a verb and an array of arguments.
  #
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Array<Entity>, Entity, String>]
    attr_reader :arguments

    # @param verb [Symbol]
    # @param arguments [Array<Array<Entity>, Entity, String>]
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
