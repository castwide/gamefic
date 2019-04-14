# Exception raised when setting a node's parent would cause
# a circular reference, e.g., A -> A or A -> B -> A
class CircularNodeReferenceError < RuntimeError; end

module Gamefic
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
      array = Array.new
      children.each { |child|
        array = array + recurse_flatten(child)
      }
      array
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
      if node == self
        raise CircularNodeReferenceError.new("Node cannot be its own parent")
      end
      # Do not permit circular references
      if node != nil and node.parent == self
        node.parent = nil
      end
      if node != nil and flatten.include?(node)
        raise CircularNodeReferenceError.new("Node cannot be a child of a descendant")
      end
      if @parent != node
        if @parent != nil
          @parent.send(:rem_child, self)
        end
        @parent = node
        if @parent != nil
          @parent.send(:add_child, self)
        end
      end
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
      array = Array.new
      array.push(node)
      node.children.each { |child|
        array = array + recurse_flatten(child)
      }
      return array
    end
  end
end
