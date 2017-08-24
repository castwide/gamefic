require "gamefic/node"
require "gamefic/describable"
require 'gamefic/messaging'

module Gamefic

  # A physical object that can exist in a plot. Most objects with which
  # players interact are entities. Player characters themselves typically
  # derive from entities, e.g., the Gamefic::Actor class.
  #
  class Entity < Element
    include Node
    include Messaging
    include Grammar::WordAdapter

    # This method is typically called by the Engine that manages game execution.
    # The base method does nothing. Subclasses can override it.
    #
    def update
    end
    
    # Set the Entity's parent.
    #
    # @param node [Gamefic::Entity] The new parent.
    def parent=(node)
      if node != nil and node.kind_of?(Entity) == false
        raise "Entity's parent must be an Entity"
      end
      super
    end

    # A freeform property dictionary.
    # Authors can use the session hash to assign custom properties to the
    # entity. It can also be referenced directly using [] without the method
    # name, e.g., entity.session[:my_value] or entity[:my_value].
    #
    # @return [Hash]
    def session
      @session ||= {}
    end

    # Get a custom property.
    #
    # @param key [Symbol] The property's name
    # @return The value of the property
    def [](key)
      session[key]
    end
    
    # Set a custom property.
    #
    # @param key [Symbol] The property's name
    # @param value The value to set
    def []=(key, value)
      session[key] = value
    end
  end

end
