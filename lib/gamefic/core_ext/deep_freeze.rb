# frozen_string_literal: true

module Gamefic
  module DeepFreeze
    # Extension for deep freezing Objects
    #
    module Object
      # Freeze an Object and all its instance variables
      #
      # @return [void]
      def deep_freeze
        freeze
        instance_variables.each do |symbol|
          ivar = instance_variable_get(symbol)
          next if ivar.frozen?

          ivar.freeze
          ivar.deep_freeze if ivar.respond_to?(:deep_freeze)
        end
      end
    end

    # Extension for deep freezing Enumerables
    #
    module Enumerable
      # Freeze an Enumerable and all its entries
      #
      # @return [void]
      def deep_freeze
        super
        each_entry do |entry|
          next if entry.frozen?

          entry.freeze
          entry.deep_freeze if entry.respond_to?(:deep_freeze)
        end
      end
    end
  end
end

Object.include Gamefic::DeepFreeze::Object
Enumerable.include Gamefic::DeepFreeze::Enumerable
