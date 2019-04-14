require 'gamefic/action'

module Gamefic
  module World
    module Commands
      include Gamefic::World::Entities

      # @return [Gamefic::World::Playbook]
      def playbook
        @playbook ||= Gamefic::World::Playbook.new
      end

      # Create an Action that responds to a command.
      # An Action uses the command argument to identify the imperative verb that
      # triggers the action.
      # It can also accept queries to tokenize the remainder of the input and
      # filter for particular entities or properties.
      # The block argument contains the code to be executed when the input
      # matches all of the Action's criteria (i.e., verb and queries).
      #
      # @example A simple Action.
      #   respond :salute do |actor|
      #     actor.tell "Hello, sir!"
      #   end
      #   # The command "salute" will respond "Hello, sir!"
      #
      # @example An Action that accepts a Character
      #   respond :salute, Use.visible(Character) do |actor, character|
      #     actor.tell "#{The character} returns your salute."
      #   end
      #
      # @param command [Symbol] An imperative verb for the command
      # @param queries [Array<Query::Base>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Class] The resulting Action subclass
      def respond(command, *queries, &proc)
        playbook.respond(command, *map_response_args(queries), &proc)
      end

      # Parse a verb and a list of arguments into an action.
      # This method serves as a shortcut to creating an action with one or more
      # arguments that identify specific entities.
      #
      # @example
      #   @thing = make Entity, name: 'a thing'
      #   parse "use", "the thing" do |actor, thing|
      #     actor.tell "You use it."
      #   end
      #
      # @param verb [String, Symbol] The command's verb
      # @param tokens [Array<String>] The arguments passed to the action
      # @return [Class] The resulting Action subclass
      def parse verb, *tokens, &proc
        query = Query::External.new(entities)
        params = []
        tokens.each do |arg|
          matches = query.resolve(nil, arg)
          raise "Unable to resolve token '#{arg}'" if matches.objects.empty?
          raise "Ambiguous results for '#{arg}'" if matches.objects.length > 1
          params.push Query::Family.new(matches.objects[0])
        end
        respond(verb.to_sym, *params, &proc)
      end

      # Tokenize and parse a command to create a new Action subclass.
      #
      # @param command [String] The command
      # @yieldparam [Gamefic::Actor]
      # @return [Class] the resulting Action subclass
      def override(command, &proc)
        cmd = Syntax.tokenize(command, playbook.syntaxes).first
        raise "Unable to tokenize command '#{command}'" if cmd.nil?
        parse cmd.verb, *cmd.arguments, &proc
      end

      # Create a Meta Action that responds to a command.
      # Meta Actions are very similar to standard Actions, except the Plot
      # understands them to be commands that operate above and/or outside of the
      # actual game world. Examples of Meta Actions are commands that report the
      # player's current score, save and restore saved games, or list the game's
      # credits.
      #
      # @example A simple Meta Action
      #   meta :credits do |actor|
      #     actor.tell "This game was written by John Smith."
      #   end
      #
      # @param command [Symbol] An imperative verb for the command
      # @param queries [Array<Query::Base>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      def meta(command, *queries, &proc)
        playbook.meta command, *queries, &proc
      end

      # @deprecated
      def action(command, *queries, &proc)
        respond command, *queries, &proc
      end

      # Declare a dismabiguation response for actions.
      # The disambigurator is executed when an action expects an argument to
      # reference a specific entity but its query matched more than one. For
      # example, "red" might refer to either a red key or a red book.
      #
      # If a disambiguator is not defined, the playbook will use its default
      # implementation.
      #
      # @example Tell the player the list of ambiguous entities.
      #   disambiguate do |actor, entities|
      #     actor.tell "I don't know which you mean: #{entities.join_or}."
      #   end
      #
      # @yieldparam [Gamefic::Actor]
      # @yieldparam [Array<Gamefic::Entity>]
      def disambiguate &block
        playbook.disambiguate &block
      end

      # Validate an order before a character can execute its command.
      #
      # @yieldparam [Gamefic::Director::Order]
      def validate &block
        playbook.validate &block
      end

      # Create an alternate Syntax for an Action.
      # The command and its translation can be parameterized.
      #
      # @example Create a synonym for the Inventory Action.
      #   interpret "catalogue", "inventory"
      #   # The command "catalogue" will be translated to "inventory"
      #
      # @example Create a parameterized synonym for the Look Action.
      #   interpret "scrutinize :entity", "look :entity"
      #   # The command "scrutinize chair" will be translated to "look chair"
      #
      # @param command [String] The format of the original command
      # @param translation [String] The format of the translated command
      # @return [Syntax] the Syntax object
      def interpret command, translation
        playbook.interpret command, translation
      end

      # @deprecated Use #interpret instead.
      def xlate command, translation
        interpret command, translation
      end

      # Get an Array of available verbs.
      #
      # @return [Array<String>]
      def verbs
        playbook.verbs.map { |v| v.to_s }.reject{ |v| v.start_with?('_') }
      end

      # Get an Array of all Actions defined in the Plot.
      #
      # @return [Array<Action>]
      def actions
        playbook.actions
      end

      def get_default_query
        @default_query_class ||= Gamefic::Query::Family
      end

      def set_default_query cls
        @default_query_class = cls
      end

      private

      def map_response_args queries
        result = []
        queries.each do |q|
          if q.is_a?(Gamefic::Query::Base)
            result.push q
          elsif q.is_a?(Gamefic::Element) or q <= Gamefic::Element
            result.push get_default_query.new(q)
          elsif q.is_a?(Regexp)
            result.push Gamefic::Query::Text.new(q)
          else
            raise ArgumentError.new("Invalid argument for response: #{q}")
          end
        end
        result
      end
    end
  end
end
