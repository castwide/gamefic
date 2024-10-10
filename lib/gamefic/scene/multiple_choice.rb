# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that presents a list of choices and processes the player's input.
    # If the input is not a valid choice, the scene gets recued.
    #
    class MultipleChoice < Default
      use_props_class Props::MultipleChoice

      def start
        super
        props.output[:options] = props.options
      end

      def finish
        super
        return if props.index

        actor.tell format(props.invalid_message, input: props.input)
        actor.recue
      end

      def run_finish_blocks
        return unless props.index

        super
      end

      def self.type
        'MultipleChoice'
      end
    end
  end
end
