# frozen_string_literal: true

module Gamefic
  module Proxy
    class Base
      attr_reader :args

      def initialize *args, raise: false
        @args = args
        @raise = raise
      end

      def raise?
        @raise
      end

      def fetch narrative
        result = select(narrative)
        return result if result
        raise "#{self.class} failed for #{args.inspect}" if raise?
      end

      def select narrative
      end
    end
  end
end
