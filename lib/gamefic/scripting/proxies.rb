# frozen_string_literal: true

module Gamefic
  module Scripting
    # Methods for referencing entities from proxies.
    #
    module Proxies
      # Convert a proxy into its referenced entity.
      #
      # This method can receive any kind of object. If it's a proxy, its entity
      # will be returned. If it's an array, each of its elements will be
      # unproxied. If it's a hash, each of its values will be unproxied. Any
      # other object will be returned unchanged.
      #
      # @param object [Object]
      # @return [Object]
      def unproxy(object)
        case object
        when Proxy::Base
          object.fetch self
        when Array
          object.map { |obj| unproxy obj }
        when Hash
          object.transform_values { |val| unproxy val }
        when Response, Query::Base
          object.bind(self)
        else
          object
        end
      end
    end
  end
end
