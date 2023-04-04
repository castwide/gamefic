module Gamefic
  module Query
    class General < Base
      def initialize entities, *args, ambiguous: false, eid: nil
        super(*args)
        @entities = entities
        @ambiguous = false
        @eid = eid
      end

      def query subject, token
        filtered = @entities.that_are(*@args)

        filtered.select! { |e| e.eid == @eid } if @eid

        scan = Scanner.scan(filtered, token)

        return ambiguous_result(scan) if ambiguous?

        unambiguous_result(scan)
      end
    end
  end
end
