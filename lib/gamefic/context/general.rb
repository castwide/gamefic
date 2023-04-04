module Gamefic
  module Context
    class General
      extend ClassMethods

      def initialize subject, entities, *args, eid: nil
        @subject = subject
        @entities = entities
        @args = args
        @eid = eid
      end

      def matches
        filtered = @entities.that_are(*@args)
        return filtered if @eid.nil?

        filtered.select { |e| e.eid == @eid }
        # @todo Handle the text now
      end
    end
  end
end
