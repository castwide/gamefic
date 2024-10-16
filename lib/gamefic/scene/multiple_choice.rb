# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that presents a list of choices. If the input does not match any
    # of the choices, the scene gets recued.
    #
    class MultipleChoice < Base
      use_props_class Props::MultipleChoice

      def start
        super
        props.output[:options] = props.options
      end

      def finish
        return super if props.selected?

        actor.tell format(props.invalid_message, input: props.input)
        actor.recue
      end

      def self.type
        'MultipleChoice'
      end
    end
  end
end
