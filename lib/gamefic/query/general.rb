# frozen_string_literal: true

module Gamefic
  module Query
    # A General query accepts an array of entities to filter. Unlike Scoped
    # queries, the resulting entities will not necessarily be in the actor's
    # immediate vicinity.
    #
    # General queries can also be passed a Proc that returns an array of
    # entities. If the Proc accepts an argument, it will be given the subject
    # of the query.
    #
    class General < Base
      # @param entities [Array, Proc]
      # @param arguments [Array<Object>]
      # @param ambiguous [Boolean]
      def initialize entities, *arguments, ambiguous: false
        super(*arguments, ambiguous: ambiguous)
        @entities = entities
      end

      def select subject
        available_entities(subject).that_are(*@arguments)
      end

      def query subject, token
        filtered = available_entities(subject).that_are(*@arguments)
        return Result.new(token, nil) if filtered.include?(token)

        scan = Scanner.scan(filtered, token)

        ambiguous? ? ambiguous_result(scan) : unambiguous_result(scan)
      end

      private

      def available_entities(subject)
        if @entities.is_a?(Proc)
          if @entities.arity.zero?
            @entities.call
          else
            @entities.call(subject)
          end
        else
          @entities
        end
      end
    end
  end
end
