# frozen_string_literal: true

module Gamefic
  module Scripting
    module Actions
      def playbook
        @playbook ||= Playbook.new
      end

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
      # @return [Response]
      def respond(verb, *queries, &proc)
        playbook.respond(verb, *map_response_args(queries), &proc)
      end

      # Create a meta rsponse for a command.
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
      # @return [Response]
      def meta(verb, *queries, &block)
        playbook.meta verb, *map_response_args(queries), &block
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
        playbook.interpret command, translation
      end

      # Define a query that searches the entire plot's entities.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def anywhere *args, eid: nil, ambiguous: false
        Query::General.new -> { entities }, *args, eid: eid, ambiguous: ambiguous
      end

      # Define a query that searches an actor's accessible entities.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def available *args, eid: nil, ambiguous: false
        Query::Scoped.new Scope::Family, *args, eid: eid, ambiguous: ambiguous
      end
      alias family available

      # Define a query that checks an actor's parent.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def parent *args, eid: nil, ambiguous: false
        Query::Scoped.new Scope::Parent, *args, eid: eid, ambiguous: ambiguous
      end

      # Define a query that searches an actor's children.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def children *args, eid: nil, ambiguous: false
        Query::Scoped.new Scope::Children, *args, eid: eid, ambiguous: ambiguous
      end

      # Define a query that searches an actor's siblings.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def siblings *args, eid: nil, ambiguous: false
        Query::Scoped.new Scope::Siblings, *args, eid: eid, ambiguous: ambiguous
      end

      # Define a query that searches the actor itself.
      #
      # @param args [Array<Object>] Query arguments
      # @param eid [Symbol] Find a specific entity by its EID
      def myself *args, eid: nil, ambiguous: false
        Query::Scoped.new Scope::Myself, *args, eid: eid, ambiguous: ambiguous
      end

      # Define a query that performs a plaintext search. It can take a String
      # or a RegExp as an argument. If no argument is provided, it will match
      # any text it finds in the command. A successful query returns the
      # corresponding text instead of an entity.
      #
      # @param arg [String, Regrxp] The string or regular expression to match
      def plaintext arg = nil
        Query::Text.new arg
      end

      private

      def map_response_args args
        args.map do |arg|
          raise "Pass `eid:` to queries instead of entities" if arg.is_a?(Gamefic::Entity)

          case arg
          when Class, Module, Symbol
            available(arg)
          when String, Regexp
            plaintext(arg)
          else
            arg
          end
        end
      end
    end
  end
end
