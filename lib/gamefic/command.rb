# frozen_string_literal: true

module Gamefic
  # A Command is a collection of tokens parsed from a Syntax.
  # Dispatchers use Commands to find and execute corresponding Actions.
  #
  class Command
    # A Symbol representing the command's verb or verbal phrase.
    #
    # @return [Symbol]
    attr_reader :verb

    # An array of arguments to be matched against response queries.
    #
    # @return [Array<String>]
    attr_reader :arguments

    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end
  end
end
