# frozen_string_literal: true

module Gamefic
  module Scope
    class Parent < Base
      # The Parent scope returns the entity's parent.
      #
      def matches
        [context.parent].compact
      end
    end
  end
end
