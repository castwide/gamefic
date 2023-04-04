module Gamefic
  module Query
    class General < Base
      def initialize entities, *arguments, ambiguous: false, eid: nil
        super(*arguments, ambiguous: ambiguous, eid: eid)
        @entities = entities
      end

      def query _subject, token
        base = @entities.is_a?(Proc) ? @entities.call : @entities
        filtered = base.that_are(*@arguments)

        filtered.select! { |e| e.eid == @eid } if @eid

        scan = Scanner.scan(filtered, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end
    end
  end
end
