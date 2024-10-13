# frozen_string_literal: true

module Gamefic
  module Proxy
    class Attr < Base
      attr_reader :name

      def initialize name, raise: true
        super
        @name = name
      end

      def select narrative
        narrative.send(name)
      rescue StandardError => e
        raise e if raise?

        Logger.warn "Proxy not found for `#{name}`"
      end
    end
  end
end
