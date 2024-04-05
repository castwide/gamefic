# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that presents a list of choices and processes the player's input.
    # If the input is not a valid choice, the scene gets recued.
    #
    class MultipleChoice < Default
      use_props_class Props::MultipleChoice

      def start actor, props
        super
        props.output[:options] = props.options
      end

      def finish actor, props
        super
        return if props.index

        actor.tell format(props.invalid_message, input: props.input)
        actor.recue
      end
    end
  end
end
