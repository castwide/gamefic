# frozen_string_literal: true

module Gamefic
  module Active
    module Epic
      def narratives
        @narratives ||= Set.new
      end
    end
  end
end
