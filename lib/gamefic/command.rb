module Gamefic
  # A Command is a collection of tokens parsed from a Syntax.
  # Playbooks use Commands to find and execute corresponding Actions.
  #
  class Command
    # A Symbol representing the command's verb or verbal phrase.
    #
    # @return [Symbol]
    attr_reader :verb

    # An Array of arguments to be mapped to an Action's Queries.
    #
    # @return [Array<String>]
    attr_reader :arguments

    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end
  end
end
