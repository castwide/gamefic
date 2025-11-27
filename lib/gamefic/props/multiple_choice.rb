# frozen_string_literal: true

module Gamefic
  module Props
    # Props for MultipleChoice scenes.
    #
    class MultipleChoice < Default
      # @return [String]
      attr_writer :invalid_message

      # The array of available options.
      #
      # @return [Array<String>]
      def options
        @options ||= []
      end

      # A message to send the player for an invalid choice. A formatting
      # token named `%<input>s` can be used to inject the user input.
      #
      # @example
      #   props.invalid_message = '"%<input>s" is not a valid choice.'
      #
      # @return [String]
      def invalid_message
        @invalid_message ||= '"%<input>s" is not a valid choice.'
      end

      # The zero-based index of the selected option.
      #
      # @return [Integer, nil]
      def index
        return nil unless input

        @index ||= index_of(input)
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

      def selected?
        !!index
      end

      # Get the index of an option using input criteria, e.g., a one-based
      # number or the text of the option. The return value is the option's
      # zero-based index or nil.
      #
      # @example
      #   props = Gamefic::Props::MultipleChoice.new
      #   props.options.push 'First choice', 'Second choice'
      #
      #   props.index_of(1)               # => 0
      #   props.index_of('Second choice') # => 1
      #
      # @param option [String, Integer]
      # @return [Integer, nil]
      def index_of(option)
        index_by_number(option) || index_by_text(option)
      end

      private

      # @param [String, Integer]
      # @return [Integer, nil]
      def index_by_number(input)
        return input.to_i - 1 if input.to_s.match(/^\d+$/) && options[input.to_i - 1]

        nil
      end

      # @param [String]
      # @return [Integer, nil]
      def index_by_text(input)
        options.find_index { |opt| opt.casecmp?(input) }
      end
    end
  end
end
