# frozen_string_literal: true

module Gamefic
  module Query
    class Global < Base
      def span subject
        return [] unless subject.is_a?(Active)

        subject.epic.narratives.flat_map(&:entities)
      end

      def precision
        @precision ||= super - 2000
      end
    end
  end
end
