# frozen_string_literal: true

module Gamefic
  module Props
    class MultipleChoice < Default
      # The zero-based index of the selected option.
      #
      # @return [Integer, nil]
      attr_accessor :index

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

      # The one-based index of the selected option.
      #
      # @return [Integer, nil]
      def number
        return nil unless index

        index + 1
      end

      # The full text of the selected option.
      #
      # @return [String, nil]
      def selection
        return nil unless index

        options[index]
      end
    end
  end
end
