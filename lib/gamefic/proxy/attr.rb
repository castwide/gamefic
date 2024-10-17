# frozen_string_literal: true

module Gamefic
  module Proxy
    class Attr < Base
      attr_reader :name

      def initialize(name)
        super
        @name = name
      end

      def select(narrative)
        narrative.send(name)
      end
    end
  end
end
