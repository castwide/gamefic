# frozen_string_literal: true

require 'gamefic/action'

module Gamefic
  module World
    module Commands
      include Entities

      # @return [Gamefic::World::Playbook]
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
      #   respond :salute, Use.visible(Character) do |actor, character|
      #     actor.tell "#{The character} returns your salute."
      #   end
      #
      # @param verb [Symbol] An imperative verb for the command
      # @param queries [Array<Query::Base, Entity>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Response]
      def respond(verb, *queries, &proc)
        playbook.respond(verb, *map_response_args(queries), &proc)
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
      # @raise [ArgumentError] if tokens are unrecognized or ambiguous
      #
      # @param verb [String, Symbol] The command's verb
      # @param tokens [Array<String>] The arguments passed to the action
      # @return [Response] The resulting response
      def parse verb, *tokens, &proc
        query = Query::External.new(entities)
        params = []
        tokens.each do |arg|
          matches = query.resolve(nil, arg)
          raise ArgumentError, "Unable to resolve token '#{arg}'" if matches.objects.empty?
          raise ArgumentError, "Ambiguous results for '#{arg}'" if matches.objects.length > 1
          params.push Query::Family.new(matches.objects[0])
        end
        respond(verb.to_sym, *params, &proc)
      end

      # Tokenize and parse a command to create a new response.
      #
      # @example Override the look response for a specific entity
      #   respond :look, Gamefic::Entity do |action, thing|
      #     actor.tell thing.description
      #   end
      #
      #   make Gamefic::Entity, name: 'a special thing'
      #
      #   override 'look special thing' do |actor, thing|
      #     actor.tell 'This thing is special!'
      #     actor.proceed
      #   end
      #
      # @param command [String] The command
      # @yieldparam [Gamefic::Actor]
      # @return [Response] the resulting response
      def override(command, &proc)
        cmd = Syntax.tokenize(command, playbook.syntaxes).first
        raise "Unable to tokenize command '#{command}'" if cmd.nil?
        parse cmd.verb, *cmd.arguments, &proc
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
      # @param queries [Array<Query::Base>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Response]
      def meta(verb, *queries, &block)
        playbook.meta verb, *queries, &block
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
      alias validate before_action

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
      alias xlate interpret

      # Get an Array of available verbs.
      #
      # @return [Array<String>]
      def verbs
        playbook.verbs.map(&:to_s).reject { |v| v.start_with?('_') }
      end

      # @return [Class<Gamefic::Query::Base>]
      def get_default_query
        @default_query_class ||= Gamefic::Query::Family
      end

      # @param cls [Class<Gamefic::Query::Base>]
      # @return [Class<Gamefic::Query::Base>]
      def set_default_query cls
        @default_query_class = cls
      end

      private

      # @param queries [Array]
      # @return [Array<Query::Base>]
      def map_response_args queries
        queries.map do |q|
          if q.is_a?(Regexp)
            Gamefic::Query::Text.new(q)
          elsif q.is_a?(Gamefic::Query::Base)
            q
          elsif q.is_a?(Gamefic::Element) || (q.is_a?(Class) && q <= Gamefic::Element)
            get_default_query.new(q)
          else
            raise ArgumentError, "Invalid argument for response: #{q.inspect}"
          end
        end
      end
    end
  end
end
