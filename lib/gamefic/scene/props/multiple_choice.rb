# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class MultipleChoice < Base
        # The zero-based index of the selected option.
        #
        # @return [Integer]
        attr_reader :index

        # The one-based index of the selected option.
        #
        # @return [Integer]
        attr_reader :number

        # The full text of the selected option.
        #
        # @return [String]
        attr_reader :selection

        # The array of available options.
        #
        # @return [Array<String>]
        def options
          @options ||= []
        end
      end
    end
  end
end
