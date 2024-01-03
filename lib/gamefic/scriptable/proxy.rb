module Gamefic
  module Scriptable
    module Proxy
      class Agent
        attr_reader :symbol

        # @param symbol [Symbol, #to_sym]
        def initialize symbol
          @symbol = symbol.to_sym
        end

        def fetch container
          if symbol.to_s.start_with?('@')
            container.instance_variable_get(symbol)
          else
            container.send(symbol)
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
