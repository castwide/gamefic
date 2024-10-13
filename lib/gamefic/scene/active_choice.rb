# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that presents a list of choices. If the input does not match any
    # of the choices, it gets executed as a command.
    #
    class ActiveChoice < Default
      use_props_class Props::MultipleChoice

      def finish
        super
        props.index || actor.perform(props.input)
      end
    end
  end
end
