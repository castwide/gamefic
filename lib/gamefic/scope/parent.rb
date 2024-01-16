# frozen_string_literal: true

module Gamefic
  module Scope
    # A query scope that can only match the entity's parent.
    #
    class Parent < Base
      def matches
        [context.parent].compact
      end
    end
  end
end
