module Gamefic
  module Query
    # Use a function to collect entities for the query. The provided
    # function can include a `subject` parameter that yields the
    # actor performing the query's action.
    #
    class Function < Base
      # @param proc [Proc] A proc to be called when querying entities
      def initialize proc, *args
        @proc = proc
        super(*args)
      end

      def context_from(subject)
        if @proc.arity == 1
          @proc.call(subject)
        else
          @proc.call
        end
      end
    end
  end
end
