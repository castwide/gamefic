# frozen_string_literal: true

module Gamefic
  module Scope
    # The Family scope returns an entity's parent, siblings, and descendants.
    #
    class Family < Base
      def matches
        result = context.parent ? [context.parent] : []
        result.concat subquery_accessible(context.parent)
        result.delete context
        context.children.each do |c|
          result.push c
          result.concat subquery_accessible(c)
        end
        result.uniq
      end
    end
  end
end
