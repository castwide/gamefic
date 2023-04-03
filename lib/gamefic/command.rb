module Gamefic
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<String>]
    attr_reader :arguments

    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end
  end
end
