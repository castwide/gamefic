# frozen_string_literal: true

module Gamefic
  module Query
    class General < Base
      # @param entities [Array, Proc]
      def initialize entities, *arguments, ambiguous: false
        super(*arguments, ambiguous: ambiguous)
        @entities = entities
      end

      def query _subject, token
        base = @entities.is_a?(Proc) ? @entities.call : @entities
        filtered = base.that_are(*@arguments)
        scan = Scanner.scan(filtered, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end
    end
  end
end
