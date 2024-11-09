# frozen_string_literal: true

module Gamefic
  module Proxy
    class Attr < Base
      def fetch(narrative)
        args.inject(narrative) { |object, key| object.send(key) }
      end
    end
  end
end
