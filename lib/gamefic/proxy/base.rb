# frozen_string_literal: true

module Gamefic
  module Proxy
    class Base
      attr_reader :args

      def initialize *args
        @args = args
      end

      def fetch(narrative); end
    end
  end
end
