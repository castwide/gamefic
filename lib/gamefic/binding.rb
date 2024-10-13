# frozen_string_literal: true

module Gamefic
  class Binding
    class << self
      def registry
        @registry ||= {}
      end

      def push object, narrative
        registry[object] ||= []
        registry[object].push narrative
      end

      def pop object
        registry[object].pop
        registry.delete(object) if registry[object].empty?
      end

      def for object
        registry.fetch(object, []).last
      end
    end

    # @param narrative [Narrative]
    # @param code [Proc]
    def initialize(narrative, code)
      @narrative = narrative
      @code = code
    end

    def call(*args)
      args.each { |arg| Binding.push arg, @narrative }
      instance_exec(*args, &@code)
    ensure
      args.each { |arg| Binding.pop arg }
    end
    alias [] call

    def method_missing(symbol, ...)
      if respond_to_missing?(symbol)
        @narrative.send(symbol, ...)
      else
        super
      end
    end

    def respond_to_missing?(symbol, _ = false)
      (@narrative.bound_methods).include?(symbol) || super
    end
  end
end
