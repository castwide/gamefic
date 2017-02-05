require "gamefic/node"
require "gamefic/describable"
require "gamefic/serialized"

module Gamefic

  class Entity
    include Node
    include Describable
    include Serialized
    extend Serialized::ClassMethods
    include Grammar::WordAdapter
    
    attr_reader :session
    serialize :name, :parent, :description
    
    def initialize(args = {})
      pre_initialize
      args.each { |key, value|
        send "#{key}=", value
      }
      @session = Hash.new
      yield self if block_given?
      post_initialize
    end

    def uid
      if @uid == nil
        @uid = self.object_id.to_s
      end
      @uid
    end

    def pre_initialize
      # raise NotImplementedError, "#{self.class} must implement post_initialize"    
    end

    def post_initialize
      # raise NotImplementedError, "#{self.class} must implement post_initialize"
    end

    def tell(message)
      #TODO: Should this even be here? In all likelihood, only Characters receive tells, right?
      #TODO: On second thought, it might be interesting to see logs from an npc point of view.
    end

    def stream(message)
      # Unlike tell, this method sends raw data without formatting.
    end
    
    # Execute the entity's on_update blocks.
    # This method is typically called by the Engine that manages game execution.
    # The base method does nothing. Subclasses can override it.
    #
    def update
    end
    
    # Set the Entity's parent.
    #
    # @param node [Entity] The new parent.
    def parent=(node)
      if node != nil and node.kind_of?(Entity) == false
        raise "Entity's parent must be an Entity"
      end
      super
    end
    
    # Get an extended property.
    #
    # @param key [Symbol] The property's name.
    def [](key)
      session[key]
    end
    
    # Set an extended property.
    #
    # @param key [Symbol] The property's name.
    # @param value The value to set.
    def []=(key, value)
      session[key] = value
    end
    
  end

end
