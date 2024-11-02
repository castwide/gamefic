# frozen_string_literal: true

module Gamefic
  module Scene
    # A scene that presents a list of optional choices. The scene can still
    # attempt to process input that does not match any of the options.
    #
    # Authors can use the `without_selection` class method to select one of
    # three actions to take when the user does not enter one of the options:
    # `:perform`, `:recue`, or `:continue`.
    #
    # * `:perform` - Skip the `on_finish` blocks and try to perform the input
    #   as a command. This is the default behavior.
    # * `:recue` - Restart the scene until the user makes a valid selection.
    #   This is the same behavior as a `MultipleChoice` scene.
    # * `:continue` - Execute the `on_finish` blocks regardless of whether the
    #   input matches an option.
    #
    class ActiveChoice < MultipleChoice
      WITHOUT_SELECTION_ACTIONS = %i[perform recue continue].freeze

      use_props_class Props::MultipleChoice

      def finish
        return super if props.selected?

        send(self.class.without_selection_action)
      end

      def without_selection_action
        self.class.without_selection_action
      end

      def self.type
        'ActiveChoice'
      end

      def self.without_selection(action)
        WITHOUT_SELECTION_ACTIONS.include?(action) ||
          raise(ArgumentError, "without_selection_action must be one of #{WITHOUT_SELECTION_ACTIONS.map(&:inspect).join_or}")

        @without_selection_action = action
      end

      def self.without_selection_action
        @without_selection_action ||= :perform
      end

      def self.inherited(klass)
        super
        klass.without_selection without_selection_action
      end

      private

      def perform
        actor.perform props.input
      end

      def recue
        actor.tell props.invalid_message
        actor.recue
      end

      def continue
        run_finish_blocks
      end
    end
  end
end
