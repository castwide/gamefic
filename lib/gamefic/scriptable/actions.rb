# frozen_string_literal: true

module Gamefic
  class FrozenPlaybookError < FrozenError; end

  module Scriptable
    # Scriptable methods related to creating actions.
    #
    module Actions
      # Create a response to a command.
      # A Response uses the `verb` argument to identify the imperative verb
      # that triggers the action. It can also accept queries to tokenize the
      # remainder of the input and filter for particular entities or
      # properties. The `block`` argument is the proc to execute when the input
      # matches all of the Response's criteria (i.e., verb and queries).
      #
      # @example A simple Action.
      #   respond :salute do |actor|
      #     actor.tell "Hello, sir!"
      #   end
      #   # The command "salute" will respond "Hello, sir!"
      #
      # @example An Action that accepts a Character
      #   respond :salute, available(Character) do |actor, character|
      #     actor.tell "#{The character} returns your salute."
      #   end
      #
      # @param verb [Symbol] An imperative verb for the command
      # @param queries [Array<Query::Base, Query::Text>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Symbol]
      def respond(verb, *queries, &proc)
        args = map_response_args(queries)
        playbook.respond_with Response.new(verb, method(:stage), *args, &proc)
        verb
      rescue FrozenError => e
        raise_frozen_playbook_error e
      end

      # Create a meta response for a command.
      # Meta responses are very similar to standard responses, except they're
      # flagged as meta (`Response#meta?`) to indicate that they provide a
      # feature that is not considered an in-game action, such as displaying
      # help documentation or a scoreboard.
      #
      # @example A simple Meta Action
      #   meta :credits do |actor|
      #     actor.tell "This game was written by John Smith."
      #   end
      #
      # @param verb [Symbol] An imperative verb for the command
      # @param queries [Array<Query::Base, Query::Text>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Symbol]
      def meta(verb, *queries, &proc)
        args = map_response_args(queries)
        playbook.respond_with Response.new(verb, method(:stage), *args, meta: true, &proc)
        verb
      rescue FrozenError => e
        raise_frozen_playbook_error e
      end

      # Add a proc to be evaluated before a character executes an action.
      # When a verb is specified, the proc will only be evaluated if the
      # action's verb matches it.
      #
      # @param verb [Symbol, nil]
      # @yieldparam [Gamefic::Action]
      # @return [Action::Hook]
      def before_action verb = nil, &block
        playbook.before_action verb, &block
      rescue FrozenError => e
        raise_frozen_playbook_error e
      end

      # Add a proc to be evaluated after a character executes an action.
      # When a verb is specified, the proc will only be evaluated if the
      # action's verb matches it.
      #
      # @param [Symbol, nil]
      # @yieldparam [Gamefic::Action]
      # @return [Action::Hook]
      def after_action verb = nil, &block
        playbook.after_action verb, &block
      rescue FrozenError => e
        raise_frozen_playbook_error e
      end

      # Create an alternate Syntax for a response.
      # The command and its translation can be parameterized.
      #
      # @example Create a synonym for an `inventory` response.
      #   interpret "catalogue", "inventory"
      #   # The command "catalogue" will be translated to "inventory"
      #
      # @example Create a parameterized synonym for a `look` response.
      #   interpret "scrutinize :entity", "look :entity"
      #   # The command "scrutinize chair" will be translated to "look chair"
      #
      # @param command [String] The format of the original command
      # @param translation [String] The format of the translated command
      # @return [Syntax] the Syntax object
      def interpret command, translation
        playbook.interpret_with Syntax.new(command, translation)
      rescue FrozenError => e
        raise_frozen_playbook_error e
      end

      # @return [Array<Symbol>]
      def verbs
        playbook.verbs
      end

      # @return [Array<Symbol>]
      def synonyms
        playbook.synonyms
      end

      # @return [Array<Syntax>]
      def syntaxes
        playbook.syntaxes
      end

      private

      def map_response_args args
        args.map do |arg|
          case arg
          when Entity
            available(Proxy.index(self, arg))
          when Class, Module, Symbol, Proc
            available(arg)
          when String, Regexp
            plaintext(arg)
          else
            arg
          end
        end
      end

      # @param e [FrozenError]
      # @return [void]
      def raise_frozen_playbook_error e
        raise FrozenPlaybookError, "can't modify frozen Playbook", e.backtrace
      end
    end
  end
end
