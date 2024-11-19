# frozen_string_literal: true

module Gamefic
  module Props
    # A MultipleChoice variant that only allows Yes or No.
    #
    class YesOrNo < MultipleChoice
      def yes?
        selection == 'Yes'
      end

      def no?
        selection == 'No'
      end

      def options
        @options ||= %w[Yes No]
      end
    end
  end
end
