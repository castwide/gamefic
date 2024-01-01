# frozen_string_literal: true

module Gamefic
  module Delegatable
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
      #   respond :salute do |actor|
      #     actor.tell "Hello, sir!"
      #   end
      #   # The command "salute" will respond "Hello, sir!"
      #
      # @example A Response that accepts a Character
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
        rulebook.calls.add_response Response.new(verb, rulebook.narrative, *args, &proc)
        verb
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
      # @param queries [Array<Query::Base, Query::Text>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Symbol]
      def meta(verb, *queries, &proc)
        args = map_response_args(queries)
        rulebook.calls.add_response Response.new(verb, rulebook.narrative, *args, meta: true, &proc)
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
        rulebook.hooks.before_action *verbs, &block
      end

      # Add a proc to be evaluated after a character executes an action.
      # When a verbs are specified, the proc will only be evaluated if the
      # action's verb matches them.
      #
      # @param verbs [Array<Symbol>]
      # @yieldparam [Gamefic::Action]
      # @return [Action::Hook]
      def after_action *verbs, &block
        rulebook.hooks.after_action *verbs, &block
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
        rulebook.calls.add_syntax Syntax.new(command, translation)
      end

      # Verbs are the symbols that have responses defined in the rulebook.
      #
      # @example
      #   class MyPlot < Gamefic::Plot
      #     script do
      #       respond :think { |actor| actor.tell 'You think.' }
      #
      #       verbs #=> [:think]
      #     end
      #   end
      #
      # @return [Array<Symbol>]
      def verbs
        rulebook.verbs
      end

      # Synonyms are a combination of the rulebook's concrete verbs plus the
      # alternative variants defined in syntaxes.
      #
      # @example
      #   class MyPlot < Gamefic::Plot
      #       respond :think { |actor| actor.tell 'You think.' }
      #       interpret 'ponder', 'think'
      #
      #       verbs #=> [:think]
      #       synonyms #=> [:think, :ponder]
      #     end
      #   end
      #
      # @return [Array<Symbol>]
      def synonyms
        rulebook.synonyms
      end

      # @return [Array<Syntax>]
      def syntaxes
        rulebook.syntaxes
      end

      private

      def map_response_args args
        args.map do |arg|
          case arg
          when Entity, Class, Module, Proc
            available(arg)
          when String, Regexp
            plaintext(arg)
          when Gamefic::Query::Base, Gamefic::Query::Text
            arg
          else
            raise ArgumentError, "invalid argument in response: #{arg.inspect}"
          end
        end
      end
    end
  end
end
