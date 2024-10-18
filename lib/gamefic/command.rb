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
    # @param meta [Boolean]
    def initialize(verb, arguments, meta = false)
      @verb = verb
      @arguments = arguments
      @meta = meta
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

    def inspect
      "#<#{self.class} #{([verb] + arguments).map(&:inspect).join(', ')}>"
    end
  end
end
