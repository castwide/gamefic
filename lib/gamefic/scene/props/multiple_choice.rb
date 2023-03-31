# frozen_string_literal: true

module Gamefic
  class Scene
    module Props
      class MultipleChoice < Base
        # The zero-based index of the selected option.
        #
        # @return [Integer]
        attr_accessor :index

        # The one-based index of the selected option.
        #
        # @return [Integer]
        attr_accessor :number

        # The full text of the selected option.
        #
        # @return [String]
        attr_accessor :selection

        # A message to send the player for an invalid choice. A formatting
        # token named %<input>s can be used to inject the user input.
        #
        # @return [String]
        attr_writer :invalid_message

        # The array of available options.
        #
        # @return [Array<String>]
        def options
          @options ||= []
        end

        def invalid_message
          @invalid_message ||= '"%<input>s" is not a valid choice.'
        end
      end
    end
  end
end
