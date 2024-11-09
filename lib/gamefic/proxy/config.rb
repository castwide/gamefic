# frozen_string_literal: true

module Gamefic
  module Proxy
    class Config < Base
      def fetch(narrative)
        args.inject(narrative.config) { |hash, key| hash[key] }
      end

      def [](key)
        args.push key
        self
      end
    end
  end
end
