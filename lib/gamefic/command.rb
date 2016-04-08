module Gamefic
  # A Command is a collection of tokens parsed from a Syntax.
  # The Director uses Commands to find and execute corresponding Actions.
  #
  class Command
    # @!attribute [r] verb
    #   @return [Symbol] A Symbol representing the command's verb or verbal phrase.
    attr_reader :verb
    
    # @!attribute [r] arguments
    #   @return [Array<String>] An Array of arguments to be mapped to an Action's Queries.
    attr_reader :arguments
    
    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end
  end
end
