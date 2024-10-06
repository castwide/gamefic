# frozen_string_literal: true

module Gamefic
  module Query
    class Myself < Base
      def span subject
        [subject]
      end
    end
  end
end
