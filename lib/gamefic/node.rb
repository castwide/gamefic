# frozen_string_literal: true

module Gamefic
  # Exception raised when setting a node's parent would cause
  # a circular reference, e.g., A -> A or A -> B -> A
  class NodeError < RuntimeError; end

  # Parent/child relationships for objects.
  #
  module Node
    # An array of the object's children.
    #
    # @return [Array]
    def children
      @children ||= []
      @children.clone
    end

    # Get a flat array of all descendants.
    #
    # @return [Array]
    def flatten
      children.flat_map { |child| recurse_flatten(child) }
    end

    # The object's parent.
    #
    # @return [Object]
    def parent
      @parent
    end

    # Set the object's parent.
    #
    def parent=(node)
      return if node == @parent

      raise NodeError, 'Parent must be a Node' unless node.is_a?(Node) || node.nil?

      raise NodeError, "Node cannot be its own parent" if node == self

      # Do not permit circular references
      node.parent = nil if node&.parent == self

      raise NodeError, 'Node cannot be a child of a descendant' if flatten.include?(node)

      return if @parent == node


      @parent&.send(:rem_child, self)
      @parent = node
      @parent&.send(:add_child, self)
    end

    # Determine if external objects can interact with this object's children.
    # For example, a game can designate that the contents of a bowl are
    # accessible, while the contents of a locked safe are not.
    #
    # @return [Boolean]
    def accessible?
      true
    end

    protected

    def add_child(node)
      children
      @children.push(node)
    end

    def rem_child(node)
      children
      @children.delete(node)
    end

    def concat_children(children)
      children.concat(children)
    end

    private

    def recurse_flatten(node)
      array = [node]
      node.children.each { |child| array += recurse_flatten(child) }
      array
    end
  end
end
