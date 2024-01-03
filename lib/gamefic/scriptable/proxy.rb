module Gamefic
  module Scriptable
    module Proxy
      class Agent
        attr_reader :symbol

        # @param symbol [Symbol, Integer]
        def initialize symbol
          @symbol = symbol
        end

        def fetch container
          if symbol.to_s =~ /^\d+$/
            Stage.run(container, symbol) { |sym| entities[sym] }
          elsif symbol.to_s.start_with?('@')
            Stage.run(container, symbol) { |sym| instance_variable_get(sym) }
          else
            Stage.run(container, symbol) { |sym| send(sym) }
          end
        end
      end

      # Proxy a method or instance variable.
      #
      # @example
      #   proxy(:method_name)
      #   proxy(:@instance_variable_name)
      #
      # @param symbol [Symbol]
      def proxy symbol
        Agent.new(symbol)
      end

      # @param object [Object]
      # @return [Object]
      def unproxy object
        case object
        when Agent
          object.fetch self
        when Array
          object.map { |obj| unproxy obj }
        when Hash
          object.transform_values { |val| unproxy val }
        else
          object
        end
      end
    end
  end
end
