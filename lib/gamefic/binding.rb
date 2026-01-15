# frozen_string_literal: true

module Gamefic
  # A lightweight wrapper around a `Proc` that executes it in the context of a
  # specific narrative.
  #
  # Gamefic stores most author-written blocks (responses, callbacks, etc.) as
  # plain Ruby procs. Those blocks are intended to run within the context of
  # their parent narrative so they can call the narrative's methods.
  # Gamefic::Binding pairs the proc with its narrative and provides a safe way
  # to execute it.
  #
  class Binding
    class << self
      # A map of objects and the stack of narratives in which they're currently
      # involved.
      #
      def registry
        @registry ||= {}
      end

      # Push a narrative to the top of an object's stack.
      #
      # @param object [Object]
      # @param narrative [Narrative]
      def push(object, narrative)
        registry[object] ||= []
        registry[object].push narrative
      end

      # Remove a narrative from the top of an object's stack.
      #
      # @param object [Object]
      def pop(object)
        registry[object].pop
        registry.delete(object) if registry[object].empty?
      end

      # Fetch the narrative at the top of an object's stack.
      #
      # @param object [Object]
      # @return [Narrative, nil]
      def for(object)
        registry.fetch(object, []).last
      end
    end

    # @return [Narrative]
    attr_reader :narrative

    # @return [Proc]
    attr_reader :code

    # @param narrative [Narrative]
    # @param code [Proc]
    def initialize(narrative, code)
      @narrative = narrative
      @code = code
    end

    # Execute the binding's code within the context of the narrative.
    #
    # @return [void]
    def call(*args)
      args.each { |arg| Binding.push arg, @narrative }
      @narrative.instance_exec(*args, &@code)
    ensure
      args.each { |arg| Binding.pop arg }
    end
    alias [] call
  end
end
