# frozen_string_literal: true

module Gamefic
  module Scriptable
    module Responses
      include Queries
      include Syntaxes

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
      # @param verb [Symbol, String, nil] An imperative verb for the command
      # @param args [Array<Object>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Response]
      def respond verb, *args, &proc
        response = Response.new(verb&.to_sym, *args, &proc)
        responses.push response
        syntaxes.push response.syntax
        response
      end

      # Create a meta response to a command.
      #
      # @param verb [Symbol, String, nil] An imperative verb for the command
      # @param args [Array<Object>] Filters for the command's tokens
      # @yieldparam [Gamefic::Actor]
      # @return [Response]
      def meta verb, *args, &proc
        response = Response.new(verb&.to_sym, *args, meta: true, &proc)
        responses.push response
        syntaxes.push response.syntax
        response
      end

      def responses
        @responses ||= []
      end

      def responses_for(*verbs)
        symbols = verbs.map { |verb| verb&.to_sym }
        responses.select { |response| symbols.include? response.verb }
      end

      def verbs
        responses.select(&:verb).uniq(&:verb)
      end
    end
  end
end
