# frozen_string_literal: true

module Gamefic
  module Props
    class MultipleChoice < Default
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

      # The zero-based index of the selected option.
      #
      # @return [Integer, nil]
      def index
        return nil unless input

        @index ||= index_by_number || index_by_text
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

      private

      def index_by_number
        return input.to_i - 1 if input.match(/^\d+$/) && options[input.to_i - 1]

        nil
      end

      def index_by_text
        options.find_index { |text| input.downcase == text.downcase }
      end
    end
  end
end
