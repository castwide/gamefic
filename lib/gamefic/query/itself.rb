module Gamefic
  module Query
    class Itself < Base
      def context_from(subject)
        [subject]
      end

      def include?(subject, object)
        return false unless accept?(object) and subject == object
      end
    end
  end
end
