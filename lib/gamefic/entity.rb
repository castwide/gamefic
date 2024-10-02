# frozen_string_literal: true

module Gamefic
  # Entities are the people, places, and things that exist in a Gamefic
  # narrative. Authors are encouraged to define Entity subclasses to create
  # entity types that have additional features or need special handling in
  # actions.
  #
  class Entity
    include Describable
    include Node

    def initialize **args
      klass = self.class
      defaults = {}
      while klass <= Entity
        defaults = klass.default_attributes.merge(defaults)
        klass = klass.superclass
      end
      defaults.merge(args).each_pair { |k, v| send "#{k}=", v }

      yield(self) if block_given?

      post_initialize
    end

    # This method can be overridden for additional processing after the entity
    # has been created.
    #
    def post_initialize; end

    # A freeform property dictionary.
    # Authors can use the session hash to assign custom properties to the
    # entity. It can also be referenced directly using [] without the method
    # name, e.g., entity.session[:my_value] or entity[:my_value].
    #
    # @return [Hash]
    def session
      @session ||= {}
    end

    # @param key [Symbol] The property's name
    # @return The value of the property
    def [](key)
      session[key]
    end

    # @param key [Symbol] The property's name
    # @param value The value to set
    def []=(key, value)
      session[key] = value
    end

    def inspect
      "#<#{self.class} #{name}>"
    end

    # Move this entity to its parent entity.
    #
    # @example
    #   room =   Gamefic::Entity.new(name: 'room')
    #   person = Gamefic::Entity.new(name: 'person', parent: room)
    #   thing =  Gamefic::Entity.new(name: 'thing', parent: person)
    #
    #   thing.parent #=> person
    #   thing.leave
    #   thing.parent #=> room
    #
    # @return [void]
    def leave
      self.parent = parent&.parent
    end

    # Tell a message to all of this entity's accessible descendants.
    #
    # @param message [String]
    # @return [void]
    def broadcast message
      Query::Scoped.new(Scope::Descendants).select(self)
                                           .that_are(Active, proc(&:acting?))
                                           .each { |actor| actor.tell message }
    end

    class << self
      # Set or update the default attributes for new instances.
      #
      def set_default **attrs
        default_attributes.merge! attrs
      end

      # A hash of default attributes when creating an instance.
      #
      # @return [Hash]
      def default_attributes
        @default_attributes ||= {}
      end
    end
  end
end
