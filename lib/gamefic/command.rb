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

    def initialize verb, arguments
      @verb = verb
      @arguments = arguments
    end
  end
end
