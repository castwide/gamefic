# frozen_string_literal: true

module Gamefic
  module Binding
    class Executor
      def initialize delegator, block
        @delegator = delegator
        @block = block
      end

      def call(*args)
        args.each { |arg| Binding.push arg, @delegator }
        instance_exec(*args, &@block)
      ensure
        args.each { |arg| Binding.pop arg }
      end
      alias [] call

      def method_missing(symbol, ...)
        if respond_to_missing?(symbol)
          @delegator.send(symbol, ...)
        else
          super
        end
      end

      def respond_to_missing?(symbol, _ = false)
        @delegator.bound_methods.include?(symbol) || super
      end
    end
  end
end
