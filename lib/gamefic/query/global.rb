# frozen_string_literal: true

module Gamefic
  module Query
    class Global < Base
      def span subject
        return [] unless subject.is_a?(Active)

        subject.epic.narratives.flat_map(&:entities)
      end
    end
  end
end
