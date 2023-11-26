# frozen_string_literal: true

module Gamefic
  module Query
    # A Scoped query uses a Scope to select entities to filter based on their
    # relationship to the entity performing the query. For example,
    # Scope::Children would filter from an array of the entity's descendants.
    #
    # @return [Class<Gamefic::Scope::Base>]
    class Scoped < Base
      attr_reader :scope

      # @param scope [Class<Gamefic::Scope::Base>]
      def initialize scope, *arguments, ambiguous: false
        super(*arguments, ambiguous: ambiguous)
        @scope = scope
      end

      # @return [Result]
      def query(subject, token)
        available = @scope.matches(subject)
                          .that_are(*unproxy(@arguments))
        scan = Scanner.scan(available, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end

      def precision
        @precision ||= @scope.precision + calculate_precision
      end

      def ambiguous?
        @ambiguous
      end
    end
  end
end
