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
        return if props.index

        actor.tell format(props.invalid_message, input: props.input)
        actor.recue
        cancel
      end
    end
  end
end
