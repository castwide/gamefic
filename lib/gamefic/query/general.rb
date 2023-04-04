module Gamefic
  module Query
    class General < Base
      def initialize entities, *args, ambiguous: false, eid: nil
        super(*args, ambiguous: ambiguous, eid: eid)
        @entities = entities
      end

      def query subject, token
        base = @entities&.call || @entities
        filtered = base.that_are(*@args)

        filtered.select! { |e| e.eid == @eid } if @eid

        scan = Scanner.scan(filtered, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end
    end
  end
end
