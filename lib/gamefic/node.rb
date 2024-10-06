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

    # Add children to the node. Return all the node's children.
    #
    # @param children [Array<Node, Array<Node>>]
    # @return [Array<Node>]
    def take *children
      children.flatten.each { |child| child.parent = self }
      children
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
    def include?(other)
      other.parent == self
    end

    def adjacent?(other)
      other.parent == parent
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
      raise NodeError, "Parent of #{inspect} must be a Node, received #{node.inspect}" unless node.is_a?(Node) || node.nil?
      raise NodeError, "#{inspect} cannot be its own parent" if node == self
      raise NodeError, "#{inspect} cannot be a child of descendant #{node.inspect}" if flatten.include?(node)
    end
  end
end
