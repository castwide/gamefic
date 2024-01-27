# frozen_string_literal: true

require 'set'

module Gamefic
  # Exception raised when setting a node's parent to an invalid object.
  #
  class NodeError < RuntimeError; end

  # Parent/child relationships for objects.
  #
  module Node
    # The object's parent.
    #
    # @return [Node, nil]
    attr_reader :parent

    # An array of the object's children.
    #
    # @return [Array<Node>]
    def children
      child_set.to_a.freeze
    end

    # Get a flat array of all descendants.
    #
    # @return [Array<Node>]
    def flatten
      children.flat_map { |child| [child] + child.flatten }
    end

    # Set the object's parent.
    #
    # @param node [Node, nil]
    def parent=(node)
      return if node == parent

      validate_parent node

      parent&.rem_child self
      @parent = node
      parent&.add_child self
    end

    # Determine if external objects can interact with this object's children.
    # For example, a game can designate that the contents of a bowl are
    # accessible, while the contents of a locked safe are not.
    #
    # @return [Boolean]
    def accessible?
      true
    end

    # True if this node is the other's parent.
    #
    # @param other [Node]
    def has?(other)
      other.parent == self
    end

    protected

    def add_child(node)
      child_set.add node
    end

    def rem_child(node)
      child_set.delete node
    end

    private

    def child_set
      @child_set ||= Set.new
    end

    def validate_parent(node)
      raise NodeError, 'Parent must be a Node' unless node.is_a?(Node) || node.nil?

      raise NodeError, "Node cannot be its own parent" if node == self

      raise NodeError, 'Node cannot be a child of a descendant' if flatten.include?(node)
    end
  end
end
