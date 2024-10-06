module Gamefic
  module Query
    # A Scoped query uses a Scope to select entities to filter based on their
    # relationship to the entity performing the query. For example,
    # Scope::Children would filter from an array of the entity's descendants.
    #
    class Scoped < Base
      attr_reader :scope

      # @param scope [Class<Gamefic::Scope::Base>]
      def initialize scope, *arguments, ambiguous: false, name: nil
        Gamefic.logger.warn '`Gamefic::Query::Scoped::Base` is deprecated. Use one of the current classes (e.g., `Gamefic::Query::Family`) instead.'
        super(*arguments, ambiguous: ambiguous, name: name)
        @scope = scope
      end

      def span(subject)
        @scope.matches(subject)
      end

      def precision
        @precision ||= @scope.precision + calculate_precision
      end
    end
  end
end
