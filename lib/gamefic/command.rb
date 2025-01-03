# frozen_string_literal: true

module Gamefic
  # A concrete representation of an input as a verb and an array of arguments.
  #
  class Command
    # @return [Symbol]
    attr_reader :verb

    # @return [Array<Array<Entity>, Entity, String>]
    attr_reader :arguments

    # @return [String, nil]
    attr_reader :input

    # @param verb [Symbol]
    # @param arguments [Array<Array<Entity>, Entity, String>]
    # @param meta [Boolean]
    # @param input [String, nil]
    def initialize(verb, arguments, meta = false, input = nil)
      @verb = verb
      @arguments = arguments
      @meta = meta
      @input = input
      @cancelled = false
    end

    def cancel
      @cancelled = true
    end
    alias stop cancel

    def cancelled?
      @cancelled
    end
    alias stopped? cancelled?

    def meta?
      @meta
    end

    def active?
      !meta?
    end

    def inspect
      "#<#{self.class} #{([verb] + arguments).map(&:inspect).join(', ')}>"
    end
  end
end
