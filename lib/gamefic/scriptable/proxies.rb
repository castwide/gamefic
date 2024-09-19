# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Methods for referencing entities from proxies.
    #
    module Proxies
      # @param object [Object]
      # @return [Object]
      def unproxy object
        case object
        when Proxy
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
