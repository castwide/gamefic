# frozen_string_literal: true

module Gamefic
  module Scriptable
    # Scriptable methods related to creating action queries.
    #
    module Queries
      include Proxies

      # Define a query that searches the entire plot's entities.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::General]
      def anywhere *args, ambiguous: false
        Query::General.new -> { entities }, *args, ambiguous: ambiguous, name: 'anywhere'
      end

      # Define a query that searches an actor's family of entities. The
      # results include the parent, siblings, children, and accessible
      # descendants of siblings and children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def available *args, ambiguous: false
        Query::Scoped.new Scope::Family, *args, ambiguous: ambiguous, name: 'available'
      end
      alias family available

      # Define a query that returns the actor's parent.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def parent *args, ambiguous: false
        Query::Scoped.new Scope::Parent, *args, ambiguous: ambiguous, name: 'parent'
      end

      # Define a query that searches an actor's children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def children *args, ambiguous: false
        Query::Scoped.new Scope::Children, *args, ambiguous: ambiguous, name: 'children'
      end

      # Define a query that searches an actor's siblings.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def siblings *args, ambiguous: false
        Query::Scoped.new Scope::Siblings, *args, ambiguous: ambiguous, name: 'siblings'
      end

      # Define a query that returns the actor itself.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Scoped]
      def myself *args, ambiguous: false
        Query::Scoped.new Scope::Myself, *args, ambiguous: ambiguous, name: 'myself'
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
