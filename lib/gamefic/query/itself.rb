module Gamefic
  module Query
    class Itself < Base
      def context_from(subject)
        [subject]
      end
    end
  end
end
