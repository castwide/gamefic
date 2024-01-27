# frozen_string_literal: true

module Gamefic
  module Scope
    # The Myself scope returns the entity itself.
    #
    class Myself < Base
      def matches
        [context]
      end
    end
  end
end
