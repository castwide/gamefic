# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating action queries.
    #
    module Queries
      # Define a query that searches all entities in the subject's epic.
      #
      # If the subject is not an actor, the result will always be empty.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Global]
      def global *args, ambiguous: false
        Query::Global.new *args, ambiguous: ambiguous, name: 'global'
      end
      alias anywhere global

      # Define a query that searches for abstract entities.
      #
      # An abstract entity is a pseudo-entity that is describable but does
      # not have a parent or children.
      #
      # If the subject is not an actor, the result will always be empty.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Abstract]
      def abstract *args, ambiguous: false
        Query::Abstract.new *args, ambiguous: ambiguous
      end

      # Define a query that searches an actor's family of entities. The
      # results include the parent, siblings, children, and accessible
      # descendants of siblings and children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def available *args, ambiguous: false
        Query::Family.new *args, ambiguous: ambiguous, name: 'available'
      end
      alias family available
      alias avail available

      # Define a query that returns the actor's parent.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def parent *args, ambiguous: false
        Query::Parent.new *args, ambiguous: ambiguous, name: 'parent'
      end

      # Define a query that searches an actor's children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def children *args, ambiguous: false
        Query::Children.new *args, ambiguous: ambiguous, name: 'children'
      end

      # Define a query that searches an actor's descendants.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def descendants *args, ambiguous: false
        Query::Descendants.new *args, ambiguous: ambiguous
      end

      # Define a query that searches an actor's siblings.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def siblings *args, ambiguous: false
        Query::Siblings.new *args, ambiguous: ambiguous, name: 'siblings'
      end

      # Define a query that returns the actor itself.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def myself *args, ambiguous: false
        Query::Myself.new *args, ambiguous: ambiguous, name: 'myself'
      end

      # Define a query that performs a plaintext search. It can take a String
      # or a RegExp as an argument. If no argument is provided, it will match
      # any text it finds in the command. A successful query returns the
      # corresponding text instead of an entity.
      #
      # @param arg [String, Regexp] The string or regular expression to match
      # @return [Query::Text]
      def plaintext arg = /.*/
        Query::Text.new arg, name: 'plaintext'
      end
    end
  end
end
