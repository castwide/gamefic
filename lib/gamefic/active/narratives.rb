# frozen_string_literal: true

module Gamefic
  module Active
    module Epic
      def narratives
        @narratives ||= Set.new
      end

      def responses
        narratives.flat_map(&:responses)
      end

      def responses_for(*verbs)
        narratives.flat_map { |narr| narr.responses_for(*verbs) }
      end

      def syntaxes
        narratives.flat_map(&:syntaxes)
      end
    end
  end
end
