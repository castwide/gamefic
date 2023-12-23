module Gamefic
  class Rulebook
    module Registry
      module_function

      def map
        @map ||= {}
      end

      # @param narrative [Narrative]
      def register narrative
        map[narrative] ||= Rulebook.new(narrative.method(:stage))
      end

      # @param narrative [Narrative]
      def unregister narrative
        map.delete narrative
      end

      # @param narrative [Narrative]
      def registered? narrative
        map.key? narrative
      end

      def clear
        map.clear
      end
    end
  end
end
