# frozen_string_literal: true

module Gamefic
  module Props
    # A subclass of MultipleChoice props that matches partial input.
    #
    class MultiplePartial < MultipleChoice
      private

      def index_by_text
        matches = options.map.with_index { |text, idx| next idx if text.downcase.start_with?(input.downcase) }.compact
        matches.first if matches.one?
      end
    end
  end
end
