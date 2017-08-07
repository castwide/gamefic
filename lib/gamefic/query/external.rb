module Gamefic
  module Query
    class External < Base
      def initialize objects, *args
        super(*args)
        @objects = objects
      end

      def context_from subject
        @objects
      end
    end
  end
end
