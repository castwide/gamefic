# frozen_string_literal: true

module Gamefic
  module Rig
    # A rig that presents a list of choices and processes the player's input.
    # If the input is not a valid choice, the scene gets recued.
    #
    class MultipleChoice < Default
      use_props_class Props::MultipleChoice

      def ready
        raise 'Options in MultipleChoice props are empty' if props.options.empty?

        props.output[:options] = props.options
      end

      def finish actor
        super
        props.index = index_by_number || index_by_text
        return if props.index

        actor.tell format(props.invalid_message, input: props.input)
        actor.recue
        cancel
      end

      private

      def index_by_number
        return props.input.to_i - 1 if props.input.match(/^\d+$/) && props.options[props.input.to_i - 1]

        nil
      end

      def index_by_text
        props.options.find_index { |text| props.input.downcase == text.downcase }
      end
    end
  end
end
