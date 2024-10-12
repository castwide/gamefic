# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating actions.
    #
    module Actions
      include Queries

      # Create a response to a command.
      # A Response uses the `verb` argument to identify the imperative verb
      # that triggers the action. It can also accept queries to tokenize the
      # remainder of the input and filter for particular entities or
      # properties. The `block`` argument is the proc to execute when the input
      # matches all of the Response's criteria (i.e., verb and queries).
      #
      # @example A simple Response.
      #   respond :wave do |actor|
      #     actor.tell "Hello!"
      #   end
      #   # The command "wave" will respond "Hello!"
      #
      # @example A Response that accepts a Character
      #   respond :salute, available(Character) do |actor, character|
      #     actor.tell "#{The character} returns your salute."
      #   end
      #
      # @param verb [Symbol] An imperative verb for the command
      # @param args [Array<Object>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Symbol]
      def respond(verb, *args, &proc)
        self.class.respond verb, *args, &proc
        verb
      end

      def interpret command, translation
        self.class.interpret command, translation
      end

      # Create a meta response for a command.
      # Meta responses are very similar to standard responses, except they're
      # flagged as meta (`Response#meta?`) to indicate that they provide a
      # feature that is not considered an in-game action, such as displaying
      # help documentation or a scoreboard.
      #
      # @example A simple meta Response
      #   meta :credits do |actor|
      #     actor.tell "This game was written by John Smith."
      #   end
      #
      # @param verb [Symbol] An imperative verb for the command
      # @param args [Array<Object>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Symbol]
      def meta(verb, *args, &proc)
        self.class.meta verb, *args, &proc
        verb
      end

      # Add a proc to be evaluated before a character executes an action.
      # When verbs are specified, the proc will only be evaluated if the
      # action's verb matches them.
      #
      # @param verbs [Array<Symbol>]
      # @yieldparam [Gamefic::Action]
      # @return [Action::Hook]
      def before_action *verbs, &block
        self.class.before_action *verbs, &block
      end

      # Add a proc to be evaluated after a character executes an action.
      # When a verbs are specified, the proc will only be evaluated if the
      # action's verb matches them.
      #
      # @param verbs [Array<Symbol>]
      # @yieldparam [Gamefic::Action]
      # @return [Action::Hook]
      def after_action *verbs, &block
        self.class.after_action *verbs, &block
      end

      def before_command *verbs, &block
        self.class.before_command *verbs, &block
      end

      def after_command *verbs, &block
        self.class.after_command *verbs, &block
      end
    end
  end
end
