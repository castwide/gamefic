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
      def global *args
        Query::Global.new(*args, name: 'global')
      end
      alias anywhere global

      # Define a query that searches an actor's family of entities. The
      # results include the parent, siblings, children, and accessible
      # descendants of siblings and children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Family]
      def available *args
        Query::Family.new(*args, name: 'available')
      end
      alias family available
      alias avail available

      # Define a query that returns the actor's parent.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Parent]
      def parent *args
        Query::Parent.new(*args, name: 'parent')
      end

      # Define a query that searches an actor's children.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Children]
      def children *args
        Query::Children.new(*args, name: 'children')
      end

      # Define a query that searches an actor's descendants.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Descendants]
      def descendants *args
        Query::Descendants.new(*args)
      end

      # Define a query that searches an actor's siblings.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Siblings]
      def siblings *args
        Query::Siblings.new(*args, name: 'siblings')
      end

      # Define a query that searches an actor's siblings and their descendants.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Extended]
      def extended *args
        Query::Extended.new(*args, name: 'extended')
      end

      # Define a query that returns the actor itself.
      #
      # @param args [Array<Object>] Query arguments
      # @return [Query::Myself]
      def myself *args
        Query::Myself.new(*args, name: 'myself')
      end

      # Define a query that performs a plaintext search. It can take a String
      # or a RegExp as an argument. If no argument is provided, it will match
      # any text it finds in the command. A successful query returns the
      # corresponding text instead of an entity.
      #
      # @param arg [String, Regexp] The string or regular expression to match
      # @return [Query::Text]
      def plaintext(arg = /.*/)
        Query::Text.new arg, name: 'plaintext'
      end

      # Define a query that matches integers. Unlike other queries, #integer
      # does not take arguments. It will match and return an integer if the
      # corresponding command token is an integer or the corresponding input is
      # a string representation of an integer. A successful query returns the
      # integer instead of an entity.
      #
      # @return [Query::Integer]
      def integer
        Query::Integer.new name: 'integer'
      end
    end
  end
end
