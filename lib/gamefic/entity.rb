# frozen_string_literal: true

module Gamefic
  class Entity
    include Describable
    include Node
    include Messaging

    def initialize **args
      klass = self.class
      defaults = {}
      while klass <= Entity
        defaults = klass.default_attributes.merge(defaults)
        klass = klass.superclass
      end
      defaults.merge(args).each_pair do |k, v|
        public_send "#{k}=", v
      end

      yield(self) if block_given?
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

    UNMARSHALED_VARIABLES = [:@next_cue, :@last_cue, :@playbooks, :@scenebooks, :@entered_scenes]

    def marshal_dump
      instance_variables.reject{|m| UNMARSHALED_VARIABLES.include? m}.inject({}) do |vars, attr|
        vars[attr] = instance_variable_get(attr)
        vars
      end
    end

    def marshal_load(vars)
      vars.each do |attr, value|
        instance_variable_set(attr, value) unless UNMARSHALED_VARIABLES.include?(attr)
      end
    end

    class << self
      # Set or update the default values for new instances.
      #
      # @param attrs [Hash] The attributes to be merged into the defaults.
      def set_default attrs = {}
        default_attributes.merge! attrs
      end

      # A hash of default values for attributes when creating an instance.
      #
      # @return [Hash]
      def default_attributes
        @default_attributes ||= {}
      end
    end
  end
end
