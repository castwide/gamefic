# frozen_string_literal: true

module Gamefic
  # A cleanroom container for running plot scripts and maintaining related
  # objects. Theaters give authors a place where they can maintain their own
  # variables and other resources without polluting the plot's namespace.
  #
  class Theater
    def evaluate director, block
      swap = self.clone
      swap.define_method_missing director
      result = swap.instance_eval &block
      swap.instance_variables.each do |iv|
        instance_variable_set iv, swap.instance_variable_get(iv)
      end
      result
    end

    def inspect
      "#<self.class>"
    end

    protected

    def define_method_missing director
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        define_singleton_method :method_missing do |symbol, *args, &block|
          director.public_send symbol, *args, &block
        end
      else
        define_singleton_method :method_missing do |symbol, *args, **splat, &block|
          director.public_send symbol, *args, **splat, &block
        end
      end
    end
  end
end
