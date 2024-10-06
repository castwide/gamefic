# frozen_string_literal: true

module Gamefic
  module Query
    class Parent < Base
      def span subject
        [subject.parent].compact
      end
    end
  end
end
