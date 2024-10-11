# frozen_string_literal: true

module Gamefic
  class Proxy
    class Attr < Base
      attr_reader :name

      def initialize name, raise: true
        super
        @name = name
      end

      def select narrative
        narrative.send(arg)
      rescue e
        raise e if raise?

        Logger.warn "Proxy not found for `#{name}`"
      end
    end
  end
end
