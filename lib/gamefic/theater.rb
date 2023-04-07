# frozen_string_literal: true

module Gamefic
  class Theater
    # A cleanroom container for running plot scripts and maintaining related
    # objects. Theaters give authors a place where they can maintain their own
    # variables and other resources without polluting the plot's namespace.
    #
    # @param director [Director] The object that will accept delegated messages
    def initialize director
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        define_singleton_method :method_missing do |symbol, *args, &block|
          director.send symbol, *args, &block
        end
      else
        define_singleton_method :method_missing do |symbol, *args, **splat, &block|
          director.send symbol, *args, **splat, &block
        end
      end
    end

    def marshal_dump
      instance_variables.inject({}) do |vars, attr|
        vars[attr] = instance_variable_get(attr)
        vars
      end
    end

    def marshal_load(vars)
      vars.each do |attr, value|
        instance_variable_set(attr, value)
      end
    end

    def inspect
      "#<self.class>"
    end
  end
end
