# frozen_string_literal: true

module Gamefic
  module Query
    class Siblings < Base
      def span subject
        subject.parent.children - [subject]
      end
    end
  end
end
