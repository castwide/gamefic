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
        available_entities(subject).that_are(*unproxied_arguments)
      end

      private

      def available_entities(subject)
        if @entities.is_a?(Proc)
          if @entities.arity.zero?
            Stage.run narrative, &@entities
          else
            Stage.run narrative, subject, &@entities
          end
        else
          @entities
        end
      end
    end
  end
end
