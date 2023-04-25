# frozen_string_literal: true

module Gamefic
  # A cleanroom container for running plot scripts and maintaining related
  # objects. Theaters give authors a place where they can maintain their own
  # variables and other resources without polluting the plot's namespace.
  #
  class Theater
    def evaluate director, *args, block
      return unless block

      define_method_missing director
      result = instance_exec *args, &block
      undefine_method_missing
      result
    end

    def inspect
      "#<self.class>"
    end

    protected

    def define_method_missing director
      if RUBY_ENGINE == 'opal' || RUBY_VERSION =~ /^2\.[456]\./
        self.class.instance_eval do
          define_method :method_missing do |symbol, *args, &block|
            director.public_send symbol, *args, &block
          end
        end
      else
        self.class.instance_eval do
          define_method :method_missing do |symbol, *args, **splat, &block|
            director.public_send symbol, *args, **splat, &block
          end
        end
      end
      self.class.instance_eval do
        define_method :stage do |*args, &block|
          send :evaluate, director, *args, &block
        end
      end
    end

    def undefine_method_missing
      # self.class.instance_eval { remove_method :method_missing }
    end
  end
end
