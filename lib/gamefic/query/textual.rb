module Gamefic
  module Query
    class Textual < Abstract
      def initialize _context, *args
        @args = args
      end

      def matches
        # @todo In all likelihood, the Textual query only needs to send its
        #   arguments, so they can be used in the Matches object (or whatever
        #   replaces Matches.)
        @args
      end
    end
  end
end
